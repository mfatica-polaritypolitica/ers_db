"""
ers_scoring.py — Enforcement Risk Score (ERS) Scoring Engine
=============================================================
Computes six component scores and a composite ERS for:
  - Sector level  : one score per ICO sector per time window
  - Org level     : one score per organisation (requires R1 org data)

Architecture
------------
Each component scorer reads from its DB tables, applies normalisation,
and returns a ComponentScore dataclass. The compositor then applies
weights and produces a final ERS.

Usage
-----
    # Score everything (sector + org) for the last 90 days
    python ers_scoring.py

    # Score a specific sector
    python ers_scoring.py --sector "Information Technology"

    # Score a specific org
    python ers_scoring.py --org "Meta Platforms Ireland"

    # Backfill scores for all historical windows
    python ers_scoring.py --backfill

    # Override weights from CLI (comma-separated, must sum to 1)
    python ers_scoring.py --weights 0.30,0.20,0.15,0.15,0.10,0.10

Schema written
--------------
    ers_component_scores  — one row per (entity_type, entity_id, component, window_end)
    ers_composite_scores  — one row per (entity_type, entity_id, window_end)

Requirements
------------
    pip install sqlalchemy psycopg2-binary pandas numpy python-dotenv
"""

from __future__ import annotations

import argparse
import logging
import os
import uuid
from dataclasses import dataclass, field
from datetime import date, datetime, timedelta, timezone
from typing import Optional

import numpy as np
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import (
    Boolean, Column, Date, Float, Integer, String, Text,
    TIMESTAMP, create_engine, text
)
from sqlalchemy.orm import DeclarativeBase, Session
from sqlalchemy.exc import IntegrityError

load_dotenv()

# ── Logging ───────────────────────────────────────────────────────────────────

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s  %(levelname)-8s  %(message)s",
    datefmt="%Y-%m-%d %H:%M:%S",
)
log = logging.getLogger(__name__)


# ── DB Connection ─────────────────────────────────────────────────────────────

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:yourpassword@localhost:5432/ers_db"
)
engine = create_engine(DATABASE_URL, echo=False, future=True)


# ── Score Output Models ───────────────────────────────────────────────────────

class Base(DeclarativeBase):
    pass


class ERSComponentScore(Base):
    """One row per component per entity per scoring window."""
    __tablename__ = "ers_component_scores"

    score_id        = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    entity_type     = Column(String(20),  nullable=False, index=True)   # 'sector' | 'org'
    entity_id       = Column(String(300), nullable=False, index=True)   # sector name or org name
    component       = Column(String(20),  nullable=False, index=True)   # regulatory | legislative | ...
    window_days     = Column(Integer,     nullable=False)               # lookback window
    window_end      = Column(Date,        nullable=False, index=True)
    raw_score       = Column(Float)                                     # pre-normalisation
    normalised_score = Column(Float)                                    # 0–1
    signal_count    = Column(Integer)                                   # number of source signals
    top_signals     = Column(Text)                                      # JSON: top 3 contributing items
    computed_at     = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))


class ERSCompositeScore(Base):
    """One row per entity per scoring window — the final ERS."""
    __tablename__ = "ers_composite_scores"

    composite_id         = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    entity_type          = Column(String(20),  nullable=False, index=True)
    entity_id            = Column(String(300), nullable=False, index=True)
    window_days          = Column(Integer,     nullable=False)
    window_end           = Column(Date,        nullable=False, index=True)
    ers_score            = Column(Float,       nullable=False)          # 0–100
    ers_band             = Column(String(20))                           # Critical / High / Medium / Low / Minimal
    regulatory_score     = Column(Float)
    legislative_score    = Column(Float)
    political_score      = Column(Float)
    judicial_score       = Column(Float)
    media_score          = Column(Float)
    complaint_score      = Column(Float)
    w_regulatory         = Column(Float)
    w_legislative        = Column(Float)
    w_political          = Column(Float)
    w_judicial           = Column(Float)
    w_media              = Column(Float)
    w_complaint          = Column(Float)
    weight_version       = Column(String(50))                           # e.g. 'v1_equal' | 'v2_calibrated'
    data_completeness    = Column(Float)                                # 0–1, fraction of components with data
    computed_at          = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))


def create_score_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    log.info("✓ Score tables ready: ers_component_scores, ers_composite_scores")


# ── Data Classes ──────────────────────────────────────────────────────────────

@dataclass
class ComponentScore:
    """Result from a single component scorer."""
    component: str
    raw_score: float                       # un-normalised, component-specific scale
    normalised_score: float                # 0.0 – 1.0
    signal_count: int = 0
    top_signals: list = field(default_factory=list)   # list of dicts for top items
    has_data: bool = True


@dataclass
class ERSWeights:
    """
    Weights for the six components. Must sum to 1.0.
    Defaults are equal weights as a starting point.
    Update these after calibration against R1 historical data.
    """
    regulatory:  float = 0.25
    legislative: float = 0.20
    political:   float = 0.15
    judicial:    float = 0.20
    media:       float = 0.10
    complaint:   float = 0.10
    version:     str   = "v1_equal"

    def validate(self):
        total = round(self.regulatory + self.legislative + self.political +
                      self.judicial + self.media + self.complaint, 6)
        if abs(total - 1.0) > 0.001:
            raise ValueError(f"Weights must sum to 1.0, got {total}")

    def as_dict(self) -> dict:
        return {
            "regulatory":  self.regulatory,
            "legislative": self.legislative,
            "political":   self.political,
            "judicial":    self.judicial,
            "media":       self.media,
            "complaint":   self.complaint,
        }


# ── Normalisation Helpers ─────────────────────────────────────────────────────

def clamp(value: float, lo: float = 0.0, hi: float = 1.0) -> float:
    return max(lo, min(hi, value))


def minmax_normalise(value: float, lo: float, hi: float) -> float:
    """Normalise value to 0–1 using known min/max bounds."""
    if hi == lo:
        return 0.0
    return clamp((value - lo) / (hi - lo))


def score_to_band(score: float) -> str:
    """Map 0–100 ERS score to a risk band label."""
    if score >= 75:
        return "Critical"
    if score >= 55:
        return "High"
    if score >= 35:
        return "Medium"
    if score >= 15:
        return "Low"
    return "Minimal"


def df_from_query(sql: str, params: dict = None) -> pd.DataFrame:
    """Run a SQL query and return a DataFrame."""
    with engine.connect() as conn:
        return pd.read_sql(text(sql), conn, params=params)


# ═══════════════════════════════════════════════════════════════════════════════
# COMPONENT SCORERS
# Each scorer takes (entity_type, entity_id, window_start, window_end)
# and returns a ComponentScore.
# ═══════════════════════════════════════════════════════════════════════════════

def score_regulatory(
    entity_type: str, entity_id: str,
    window_start: date, window_end: date
) -> ComponentScore:
    """
    Regulatory score — drawn from R1 enforcement, R2 news, R3 consultations.

    Signal sources:
      R1: Recent enforcement actions (severity-weighted)
      R2: ICO news/signals (investigation flags, enforcement signals)
      R3: Open consultations with high enforcement signal
    """

    # ── R1: Enforcement actions ───────────────────────────────────────────────
    if entity_type == "sector":
        # Sector-level: match org_type roughly to sector name
        r1_sql = """
            SELECT action_type, penalty_gbp, severity_tier,
                   enforcement_signal, org_name, action_date
            FROM r1_enforcement_register
            WHERE action_date BETWEEN :start AND :end
              AND LOWER(org_type) LIKE LOWER(:sector_pat)
            ORDER BY action_date DESC
        """
        r1_df = df_from_query(r1_sql, {
            "start": window_start, "end": window_end,
            "sector_pat": f"%{entity_id.split()[0]}%"
        })
    else:
        # Org-level: exact match on org_name
        r1_sql = """
            SELECT action_type, penalty_gbp, severity_tier,
                   enforcement_signal, org_name, action_date
            FROM r1_enforcement_register
            WHERE action_date BETWEEN :start AND :end
              AND LOWER(org_name) LIKE LOWER(:org_pat)
            ORDER BY action_date DESC
        """
        r1_df = df_from_query(r1_sql, {
            "start": window_start, "end": window_end,
            "org_pat": f"%{entity_id}%"
        })

    # Severity tier multipliers
    severity_weights = {
        "Critical": 1.0, "High": 0.75, "Medium": 0.50,
        "Low": 0.25, "Advisory": 0.10
    }

    r1_score = 0.0
    for _, row in r1_df.iterrows():
        sw = severity_weights.get(row.get("severity_tier", "Medium"), 0.5)
        # Penalty boost: log-scale so £100k and £10m don't dwarf everything
        penalty_boost = 0.0
        if row.get("penalty_gbp") and row["penalty_gbp"] > 0:
            penalty_boost = min(np.log10(float(row["penalty_gbp"])) / 8.0, 0.5)
        r1_score += (sw + penalty_boost)

    # ── R2: ICO news signals ──────────────────────────────────────────────────
    r2_sql = """
        SELECT enforcement_signal, signal_investigation, topic_relevance_score
        FROM r2_ico_news
        WHERE publication_date BETWEEN :start AND :end
          AND topic_relevance_score >= 0.3
    """
    r2_df = df_from_query(r2_sql, {"start": window_start, "end": window_end})

    r2_score = 0.0
    if not r2_df.empty:
        r2_score = (
            r2_df["enforcement_signal"].fillna(0).mean() * 0.5 +
            r2_df["signal_investigation"].fillna(False).astype(float).mean() * 0.5
        )

    # ── R3: Open high-signal consultations ───────────────────────────────────
    r3_sql = """
        SELECT enforcement_signal, consultation_status, obligation_direction
        FROM r3_ico_consultations
        WHERE publication_date BETWEEN :start AND :end
          AND enforcement_signal >= 0.4
    """
    r3_df = df_from_query(r3_sql, {"start": window_start, "end": window_end})

    r3_score = 0.0
    if not r3_df.empty:
        open_mask = r3_df["consultation_status"].isin(["Open", "Closed"])
        r3_score = r3_df.loc[open_mask, "enforcement_signal"].fillna(0).sum() * 0.3

    # Combine: R1 dominates, R2 and R3 add context
    raw = r1_score * 0.60 + r2_score * 0.25 + r3_score * 0.15

    # Normalise: cap at 5 R1 enforcement actions as "max signal"
    normalised = clamp(raw / 5.0)

    top_signals = r1_df.head(3)[["org_name", "action_type", "severity_tier", "action_date"]].to_dict("records") if not r1_df.empty else []

    return ComponentScore(
        component="regulatory",
        raw_score=raw,
        normalised_score=normalised,
        signal_count=len(r1_df) + len(r2_df) + len(r3_df),
        top_signals=top_signals,
        has_data=not (r1_df.empty and r2_df.empty and r3_df.empty),
    )


def score_legislative(
    entity_type: str, entity_id: str,
    window_start: date, window_end: date
) -> ComponentScore:
    """
    Legislative score — drawn from L1 bills and L2 statutory instruments.

    Higher score when:
      - Bills at advanced stages (Third Reading, Royal Assent)
      - High relevance bills are active
      - SIs are coming into force imminently
    """
    # L1: Bills
    l1_sql = """
        SELECT bill_title, event_type, bill_stage_numeric, bill_status,
               relevance_score, affects_ico, event_date
        FROM l1_bills_in_parliament
        WHERE event_date BETWEEN :start AND :end
          AND relevance_score >= 0.3
        ORDER BY bill_stage_numeric DESC, relevance_score DESC
    """
    l1_df = df_from_query(l1_sql, {"start": window_start, "end": window_end})

    l1_score = 0.0
    if not l1_df.empty:
        # Stage multiplier: later stage = higher risk signal
        l1_df["stage_weight"] = l1_df["bill_stage_numeric"].apply(
            lambda s: min(s / 10.0, 1.0) if pd.notna(s) else 0.1
        )
        l1_score = (
            l1_df["relevance_score"].fillna(0) *
            l1_df["stage_weight"]
        ).sum()

    # L2: SIs — especially those coming into force soon
    l2_sql = """
        SELECT si_title, si_type, si_status, relevance_score,
               force_date, made_date, affects_ico
        FROM l2_statutory_instruments
        WHERE (made_date BETWEEN :start AND :end
               OR force_date BETWEEN :start AND :end2)
          AND relevance_score >= 0.3
        ORDER BY relevance_score DESC
    """
    # Look forward 90 days for imminent SIs
    forward_end = window_end + timedelta(days=90)
    l2_df = df_from_query(l2_sql, {
        "start": window_start, "end": window_end, "end2": forward_end
    })

    l2_score = 0.0
    if not l2_df.empty:
        # Imminent SIs (coming into force within 90 days) get a boost
        today = date.today()
        def imminence_boost(row):
            if pd.isna(row.get("force_date")):
                return 1.0
            days = (row["force_date"] - today).days
            if 0 <= days <= 30:
                return 2.0
            if 0 <= days <= 90:
                return 1.5
            return 1.0

        l2_df["boost"] = l2_df.apply(imminence_boost, axis=1)
        l2_score = (l2_df["relevance_score"].fillna(0) * l2_df["boost"]).sum() * 0.5

    raw = l1_score + l2_score
    normalised = clamp(raw / 6.0)   # cap at ~6 active relevant bills/SIs

    top_signals = l1_df.head(3)[["bill_title", "event_type", "bill_stage_numeric"]].to_dict("records") if not l1_df.empty else []

    return ComponentScore(
        component="legislative",
        raw_score=raw,
        normalised_score=normalised,
        signal_count=len(l1_df) + len(l2_df),
        top_signals=top_signals,
        has_data=not (l1_df.empty and l2_df.empty),
    )


def score_political(
    entity_type: str, entity_id: str,
    window_start: date, window_end: date
) -> ComponentScore:
    """
    Political score — drawn from P1 speeches, P6 Q&A.

    Higher score when:
      - Ministers are making pro-enforcement speeches
      - Parliamentary Q&A shows government is "Supportive of Enforcement"
      - High ICO mention rate in recent political discourse
    """
    # P1: Government speeches
    p1_sql = """
        SELECT topic_relevance_score, regulatory_stance, enforcement_signal,
               ico_mentioned, priority_level, department, speech_date
        FROM p1_government_speeches
        WHERE speech_date BETWEEN :start AND :end
          AND topic_relevance_score >= 0.25
        ORDER BY topic_relevance_score DESC
    """
    p1_df = df_from_query(p1_sql, {"start": window_start, "end": window_end})

    p1_score = 0.0
    if not p1_df.empty:
        stance_map = {"Pro-enforcement": 1.0, "Mixed": 0.6, "Neutral": 0.4, "Deregulatory": 0.1}
        p1_df["stance_weight"] = p1_df["regulatory_stance"].map(stance_map).fillna(0.4)
        p1_score = (
            p1_df["topic_relevance_score"].fillna(0) *
            p1_df["stance_weight"] *
            p1_df["enforcement_signal"].fillna(0.4)
        ).sum()

    # P6: Parliamentary Q&A
    p6_sql = """
        SELECT topic_relevance_score, government_position, enforcement_signal,
               ico_mentioned, question_date
        FROM p6_parliamentary_qa
        WHERE question_date BETWEEN :start AND :end
          AND topic_relevance_score >= 0.25
        ORDER BY topic_relevance_score DESC
    """
    p6_df = df_from_query(p6_sql, {"start": window_start, "end": window_end})

    p6_score = 0.0
    if not p6_df.empty:
        position_map = {
            "Supportive of Enforcement": 1.0,
            "Neutral": 0.5,
            "Resistant": 0.1,
            "Unclear": 0.4,
        }
        p6_df["pos_weight"] = p6_df["government_position"].map(position_map).fillna(0.4)
        p6_score = (
            p6_df["topic_relevance_score"].fillna(0) * p6_df["pos_weight"]
        ).sum() * 0.5

    raw = p1_score + p6_score
    normalised = clamp(raw / 5.0)

    top_signals = p1_df.head(3)[["department", "regulatory_stance", "speech_date"]].to_dict("records") if not p1_df.empty else []

    return ComponentScore(
        component="political",
        raw_score=raw,
        normalised_score=normalised,
        signal_count=len(p1_df) + len(p6_df),
        top_signals=top_signals,
        has_data=not (p1_df.empty and p6_df.empty),
    )


def score_judicial(
    entity_type: str, entity_id: str,
    window_start: date, window_end: date
) -> ComponentScore:
    """
    Judicial score — drawn from J1–J4 court and tribunal tables.

    Higher score when:
      - Recent ICO wins (ICO position upheld)
      - Cases widening controller liability
      - Binding precedents from higher courts
    """
    tables = [
        ("j1_supreme_court",              "supreme_id",  "Binding",           "decision_date"),
        ("j2_court_of_appeal",            "appeal_id",   "Binding",           "decision_date"),
        ("j3_information_rights_tribunal","tribunal_id", "Persuasive",        "decision_date"),
        ("j4_high_court",                 "highcourt_id","Binding",           "decision_date"),
    ]

    total_score = 0.0
    total_count = 0
    top_signals = []

    precedent_weights = {"Binding": 1.0, "Highly Persuasive": 0.7, "Persuasive": 0.4}

    for table, pk, default_precedent, date_col in tables:
        sql = f"""
            SELECT enforcement_signal, ico_position_upheld,
                   widens_controller_liability, precedent_weight,
                   outcome_direction, ai_specific, {date_col}
            FROM {table}
            WHERE {date_col} BETWEEN :start AND :end
        """
        try:
            df = df_from_query(sql, {"start": window_start, "end": window_end})
        except Exception:
            continue   # table may not exist yet

        if df.empty:
            continue

        for _, row in df.iterrows():
            pw    = precedent_weights.get(row.get("precedent_weight", default_precedent), 0.4)
            es    = float(row.get("enforcement_signal") or 0.5)
            ico_w = 1.2 if row.get("ico_position_upheld") else 0.8
            ai_b  = 1.1 if row.get("ai_specific") else 1.0
            wid_b = 1.15 if row.get("widens_controller_liability") else 1.0
            total_score += es * pw * ico_w * ai_b * wid_b

        total_count += len(df)
        top_signals += df.head(2)[["outcome_direction", "enforcement_signal", date_col]].to_dict("records")

    normalised = clamp(total_score / 4.0)

    return ComponentScore(
        component="judicial",
        raw_score=total_score,
        normalised_score=normalised,
        signal_count=total_count,
        top_signals=top_signals[:3],
        has_data=total_count > 0,
    )


def score_media(
    entity_type: str, entity_id: str,
    window_start: date, window_end: date
) -> ComponentScore:
    """
    Media and civil society score — drawn from M1 NGO activity, M2 press.

    Higher score when:
      - Tier 1 outlets are covering enforcement stories
      - NGOs have filed formal complaints or legal challenges
      - ICO is directly mentioned in action contexts
    """
    # M1: NGO activity
    if entity_type == "org":
        m1_sql = """
            SELECT ngo_name, activity_type, topic_relevance_score,
                   formal_complaint, legal_action, ico_named, publication_date
            FROM m1_ngo_activity
            WHERE publication_date BETWEEN :start AND :end
              AND (LOWER(title) LIKE LOWER(:org_pat) OR ico_named = TRUE)
              AND topic_relevance_score >= 0.2
            ORDER BY topic_relevance_score DESC
        """
        m1_df = df_from_query(m1_sql, {
            "start": window_start, "end": window_end,
            "org_pat": f"%{entity_id}%"
        })
    else:
        m1_sql = """
            SELECT ngo_name, activity_type, topic_relevance_score,
                   formal_complaint, legal_action, ico_named, publication_date
            FROM m1_ngo_activity
            WHERE publication_date BETWEEN :start AND :end
              AND topic_relevance_score >= 0.3
            ORDER BY topic_relevance_score DESC
        """
        m1_df = df_from_query(m1_sql, {"start": window_start, "end": window_end})

    m1_score = 0.0
    if not m1_df.empty:
        type_weights = {
            "Legal Challenge": 1.5, "Formal Complaint": 1.3,
            "Parliamentary Submission": 1.0, "Open Letter": 0.8,
            "Report": 0.7, "Press Release": 0.5, "Publication": 0.4,
        }
        m1_df["type_w"] = m1_df["activity_type"].map(type_weights).fillna(0.5)
        m1_df["action_boost"] = (
            m1_df["formal_complaint"].fillna(False).astype(float) * 0.3 +
            m1_df["legal_action"].fillna(False).astype(float) * 0.5 + 1.0
        )
        m1_score = (
            m1_df["topic_relevance_score"].fillna(0) *
            m1_df["type_w"] *
            m1_df["action_boost"]
        ).sum()

    # M2: Press coverage
    if entity_type == "org":
        m2_sql = """
            SELECT outlet, outlet_tier, story_type, topic_relevance_score,
                   ico_mentioned, ico_action, publication_date
            FROM m2_media_press
            WHERE publication_date BETWEEN :start AND :end
              AND (LOWER(headline) LIKE LOWER(:org_pat) OR ico_mentioned = TRUE)
              AND topic_relevance_score >= 0.2
            ORDER BY outlet_tier ASC, topic_relevance_score DESC
        """
        m2_df = df_from_query(m2_sql, {
            "start": window_start, "end": window_end,
            "org_pat": f"%{entity_id}%"
        })
    else:
        m2_sql = """
            SELECT outlet, outlet_tier, story_type, topic_relevance_score,
                   ico_mentioned, ico_action, publication_date
            FROM m2_media_press
            WHERE publication_date BETWEEN :start AND :end
              AND topic_relevance_score >= 0.3
            ORDER BY outlet_tier ASC, topic_relevance_score DESC
        """
        m2_df = df_from_query(m2_sql, {"start": window_start, "end": window_end})

    m2_score = 0.0
    if not m2_df.empty:
        tier_weights = {1: 1.0, 2: 0.6, 3: 0.3}
        story_weights = {
            "Investigation": 1.5, "Data Breach": 1.3,
            "Regulatory Response": 1.2, "News": 0.7,
            "Opinion": 0.5, "Profile": 0.4,
        }
        m2_df["tier_w"]  = m2_df["outlet_tier"].map(tier_weights).fillna(0.3)
        m2_df["story_w"] = m2_df["story_type"].map(story_weights).fillna(0.7)
        m2_df["ico_b"]   = m2_df["ico_action"].fillna(False).astype(float) * 0.3 + 1.0
        m2_score = (
            m2_df["topic_relevance_score"].fillna(0) *
            m2_df["tier_w"] *
            m2_df["story_w"] *
            m2_df["ico_b"]
        ).sum() * 0.5

    raw = m1_score + m2_score
    normalised = clamp(raw / 6.0)

    top_signals = m1_df.head(2)[["ngo_name", "activity_type", "publication_date"]].to_dict("records") if not m1_df.empty else []

    return ComponentScore(
        component="media",
        raw_score=raw,
        normalised_score=normalised,
        signal_count=len(m1_df) + len(m2_df),
        top_signals=top_signals,
        has_data=not (m1_df.empty and m2_df.empty),
    )


def score_complaint_volume(
    entity_type: str, entity_id: str,
    window_start: date, window_end: date
) -> ComponentScore:
    """
    Complaint volume score — drawn from I1 volume statistics and I2 scores.

    Higher score when:
      - Complaint counts are above the 3-period rolling average (spike)
      - Trend is Rising
      - Sector risk modifier is elevated
    """
    if entity_type == "sector":
        i2_sql = """
            SELECT volume_factor, trend_direction, spike_active,
                   sector_risk_modifier, stale_flag,
                   ref_period_end, ico_sector
            FROM i2_volume_scores
            WHERE ico_sector ILIKE :sector_pat
            ORDER BY ref_period_end DESC
            LIMIT 1
        """
        i2_df = df_from_query(i2_sql, {"sector_pat": f"%{entity_id.split()[0]}%"})
    else:
        # For org-level, use the sector the org belongs to (fallback: all sectors)
        i2_sql = """
            SELECT volume_factor, trend_direction, spike_active,
                   sector_risk_modifier, stale_flag, ref_period_end, ico_sector
            FROM i2_volume_scores
            ORDER BY sector_risk_modifier DESC NULLS LAST
            LIMIT 5
        """
        i2_df = df_from_query(i2_sql, {})

    if i2_df.empty:
        return ComponentScore(
            component="complaint",
            raw_score=0.0,
            normalised_score=0.0,
            signal_count=0,
            has_data=False,
        )

    row = i2_df.iloc[0]

    # Penalise stale data
    stale_penalty = 0.7 if row.get("stale_flag") else 1.0

    volume_factor  = float(row.get("volume_factor") or 1.0)
    trend_mult     = {"Rising": 1.2, "Stable": 1.0, "Falling": 0.8}.get(
                         row.get("trend_direction"), 1.0)
    spike_mult     = 1.5 if row.get("spike_active") else 1.0
    sector_risk    = float(row.get("sector_risk_modifier") or volume_factor)

    raw = sector_risk * stale_penalty
    normalised = clamp(minmax_normalise(raw, 0.5, 3.0))

    return ComponentScore(
        component="complaint",
        raw_score=raw,
        normalised_score=normalised,
        signal_count=len(i2_df),
        top_signals=[{
            "sector": row.get("ico_sector"),
            "trend": row.get("trend_direction"),
            "spike": row.get("spike_active"),
            "volume_factor": volume_factor,
        }],
        has_data=True,
    )


# ═══════════════════════════════════════════════════════════════════════════════
# COMPOSITOR
# ═══════════════════════════════════════════════════════════════════════════════

def compute_ers(
    entity_type: str,
    entity_id: str,
    weights: ERSWeights,
    window_days: int = 90,
    window_end: date = None,
) -> ERSCompositeScore:
    """
    Compute a full ERS for one entity.

    Parameters
    ----------
    entity_type : 'sector' or 'org'
    entity_id   : sector name or org name
    weights     : ERSWeights instance
    window_days : lookback window in days
    window_end  : end of window (defaults to today)

    Returns
    -------
    ERSCompositeScore ORM object (not yet committed to DB)
    """
    weights.validate()

    if window_end is None:
        window_end = date.today()
    window_start = window_end - timedelta(days=window_days)

    log.info(f"  Scoring {entity_type}: '{entity_id}' | "
             f"{window_start} → {window_end} | weights={weights.version}")

    # Run all six component scorers
    scorers = [
        score_regulatory,
        score_legislative,
        score_political,
        score_judicial,
        score_media,
        score_complaint_volume,
    ]

    component_scores: dict[str, ComponentScore] = {}
    for scorer in scorers:
        try:
            cs = scorer(entity_type, entity_id, window_start, window_end)
        except Exception as e:
            log.warning(f"    Component scorer {scorer.__name__} failed: {e}")
            cs = ComponentScore(
                component=scorer.__name__.replace("score_", ""),
                raw_score=0.0, normalised_score=0.0,
                has_data=False,
            )
        component_scores[cs.component] = cs

    w = weights.as_dict()

    # Weighted sum — if a component has no data, redistribute its weight
    # proportionally among components that do have data, so the score
    # doesn't deflate just because a table hasn't been populated yet.
    components_with_data = {k: v for k, v in component_scores.items() if v.has_data}
    data_completeness    = len(components_with_data) / len(component_scores)

    if components_with_data:
        total_weight_available = sum(w[k] for k in components_with_data)
        ers_raw = sum(
            component_scores[k].normalised_score * (w[k] / total_weight_available)
            for k in components_with_data
        )
    else:
        ers_raw = 0.0

    ers_score = round(ers_raw * 100, 2)

    return ERSCompositeScore(
        entity_type       = entity_type,
        entity_id         = entity_id,
        window_days       = window_days,
        window_end        = window_end,
        ers_score         = ers_score,
        ers_band          = score_to_band(ers_score),
        regulatory_score  = component_scores.get("regulatory",  ComponentScore("regulatory",  0, 0)).normalised_score,
        legislative_score = component_scores.get("legislative", ComponentScore("legislative", 0, 0)).normalised_score,
        political_score   = component_scores.get("political",   ComponentScore("political",   0, 0)).normalised_score,
        judicial_score    = component_scores.get("judicial",    ComponentScore("judicial",    0, 0)).normalised_score,
        media_score       = component_scores.get("media",       ComponentScore("media",       0, 0)).normalised_score,
        complaint_score   = component_scores.get("complaint",   ComponentScore("complaint",   0, 0)).normalised_score,
        w_regulatory      = w["regulatory"],
        w_legislative     = w["legislative"],
        w_political       = w["political"],
        w_judicial        = w["judicial"],
        w_media           = w["media"],
        w_complaint       = w["complaint"],
        weight_version    = weights.version,
        data_completeness = data_completeness,
    )


def save_composite_score(composite: ERSCompositeScore, session: Session):
    """Upsert a composite score (replace if same entity+window_end already exists)."""
    existing = session.query(ERSCompositeScore).filter_by(
        entity_type=composite.entity_type,
        entity_id=composite.entity_id,
        window_days=composite.window_days,
        window_end=composite.window_end,
        weight_version=composite.weight_version,
    ).first()
    if existing:
        session.delete(existing)
        session.flush()
    session.add(composite)


# ═══════════════════════════════════════════════════════════════════════════════
# SECTOR & ORG RUNNERS
# ═══════════════════════════════════════════════════════════════════════════════

# Default sector list — derived from ICO's own sector taxonomy used in I1/I2
DEFAULT_SECTORS = [
    "Information Technology",
    "Finance, Insurance and Credit",
    "Health",
    "Education and Childcare",
    "Central Government",
    "Local Government",
    "Retail and Manufacture",
    "Telecoms and Internet",
    "Political Organisations",
    "Media and Publishing",
    "Legal Services",
    "Justice and Emergency Services",
]


def run_sector_scores(
    weights: ERSWeights,
    window_days: int = 90,
    sectors: list[str] = None,
    backfill: bool = False,
):
    """Score all sectors (or a subset) and persist to DB."""
    create_score_tables()
    sectors = sectors or DEFAULT_SECTORS

    # For backfill: score quarterly windows going back 3 years
    if backfill:
        today = date.today()
        window_ends = [today - timedelta(days=90 * i) for i in range(12)]
    else:
        window_ends = [date.today()]

    with Session(engine) as session:
        for sector in sectors:
            for we in window_ends:
                composite = compute_ers(
                    entity_type="sector",
                    entity_id=sector,
                    weights=weights,
                    window_days=window_days,
                    window_end=we,
                )
                save_composite_score(composite, session)
                log.info(f"    {sector:40s}  ERS={composite.ers_score:5.1f}  "
                         f"({composite.ers_band})  completeness={composite.data_completeness:.0%}")
        session.commit()
    log.info(f"✓ Sector scores saved | {len(sectors)} sectors × {len(window_ends)} windows")


def run_org_scores(
    weights: ERSWeights,
    window_days: int = 90,
    org_names: list[str] = None,
    backfill: bool = False,
):
    """
    Score organisations found in R1 enforcement register.
    If org_names is provided, score only those orgs.
    """
    create_score_tables()

    if org_names:
        orgs = org_names
    else:
        # Pull distinct orgs from the enforcement register
        df = df_from_query("""
            SELECT DISTINCT org_name FROM r1_enforcement_register
            ORDER BY org_name
        """)
        orgs = df["org_name"].tolist() if not df.empty else []

    if not orgs:
        log.warning("No organisations found to score.")
        return

    window_ends = [date.today() - timedelta(days=90 * i) for i in range(4)] \
                  if backfill else [date.today()]

    with Session(engine) as session:
        for org in orgs:
            for we in window_ends:
                composite = compute_ers(
                    entity_type="org",
                    entity_id=org,
                    weights=weights,
                    window_days=window_days,
                    window_end=we,
                )
                save_composite_score(composite, session)
                log.info(f"    {org[:40]:40s}  ERS={composite.ers_score:5.1f}  ({composite.ers_band})")
        session.commit()
    log.info(f"✓ Org scores saved | {len(orgs)} orgs × {len(window_ends)} windows")


# ═══════════════════════════════════════════════════════════════════════════════
# CLI ENTRY POINT
# ═══════════════════════════════════════════════════════════════════════════════

def parse_weights(weights_str: str) -> ERSWeights:
    """Parse comma-separated weight string into ERSWeights."""
    parts = [float(x.strip()) for x in weights_str.split(",")]
    if len(parts) != 6:
        raise ValueError("--weights must have exactly 6 values: regulatory,legislative,political,judicial,media,complaint")
    return ERSWeights(
        regulatory=parts[0], legislative=parts[1], political=parts[2],
        judicial=parts[3],   media=parts[4],       complaint=parts[5],
        version="cli_custom",
    )


def run(
    weights: ERSWeights = None,
    sector: str = None,
    org: str = None,
    window_days: int = 90,
    backfill: bool = False,
):
    """Main entry point. Called directly or imported."""
    if weights is None:
        weights = ERSWeights()   # defaults to equal weights

    log.info("=" * 60)
    log.info(f"ERS Scoring Engine | weights={weights.version} | window={window_days}d")
    log.info("=" * 60)

    if sector:
        run_sector_scores(weights, window_days, sectors=[sector], backfill=backfill)
    elif org:
        run_org_scores(weights, window_days, org_names=[org], backfill=backfill)
    else:
        log.info("── Sector scores ─────────────────────────────────────────")
        run_sector_scores(weights, window_days, backfill=backfill)
        log.info("── Org scores ────────────────────────────────────────────")
        run_org_scores(weights, window_days, backfill=backfill)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="ERS Scoring Engine")
    parser.add_argument("--sector",   type=str, default=None,
                        help="Score a single sector by name")
    parser.add_argument("--org",      type=str, default=None,
                        help="Score a single organisation by name")
    parser.add_argument("--window",   type=int, default=90,
                        help="Lookback window in days (default: 90)")
    parser.add_argument("--backfill", action="store_true",
                        help="Score historical windows (quarterly, last 3 years)")
    parser.add_argument("--weights",  type=str, default=None,
                        help="Comma-separated weights: reg,leg,pol,jud,med,comp (must sum to 1)")
    args = parser.parse_args()

    w = parse_weights(args.weights) if args.weights else ERSWeights()
    run(weights=w, sector=args.sector, org=args.org,
        window_days=args.window, backfill=args.backfill)
