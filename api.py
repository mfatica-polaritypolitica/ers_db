"""
api.py — REG-1 ERS FastAPI Backend  (v2 — wired to ers_scoring.py)
====================================================================
Primary change vs v1: the /api/v1/score endpoint now reads from the
pre-computed ers_composite_scores and ers_component_scores tables that
ers_scoring.py writes to, rather than re-computing from scratch on
every request.

Fallback: if no pre-computed score exists, it calls compute_ers() live.

Run with:
    uvicorn api:app --reload --port 8000

Environment variable required:
    DATABASE_URL=postgresql://user:password@host:5432/ers_db
"""

from __future__ import annotations

import sys
from pathlib import Path

# Add models/ subfolder to path
_models_dir = Path(__file__).parent / 'models'
if str(_models_dir) not in sys.path:
    sys.path.insert(0, str(_models_dir))

import json
import os
from datetime import date, datetime, timezone
from typing import Optional

from fastapi import FastAPI, Query, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from sqlalchemy import desc, text
from sqlalchemy.orm import Session

# ── ERS scoring engine + output ORM models ────────────────────────────────────
from ers_scoring import (
    engine as _base_engine,
    ERSWeights,
    ERSCompositeScore,
    ERSComponentScore,
    compute_ers,
    df_from_query,
    DEFAULT_SECTORS,
)

# Use Railway DATABASE_URL env var if present, otherwise use scoring engine default
import os as _os
from sqlalchemy import create_engine as _create_engine
_db_url = _os.environ.get('DATABASE_URL')
engine = _create_engine(_db_url, echo=False, future=True) if _db_url else _base_engine

# ── Raw signal models ─────────────────────────────────────────────────────────
from legislative_models import L1Bill, L2StatutoryInstrument
from regulatory_models  import R1EnforcementRegister, R2IcoNews, R3IcoConsultations
from political_models   import P1GovernmentSpeeches, P3BudgetDocuments
from media_models       import M1NgoActivity, M2MediaPress
from judicial_models    import J2CourtOfAppeal, J3InformationRightsTribunal


# ── App ───────────────────────────────────────────────────────────────────────

app = FastAPI(
    title="REG-1 ERS API",
    description="Enforcement Risk Score API — v2, reads from ers_scoring.py output tables",
    version="2.0.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],        # open during local dev — lock down before production
    allow_methods=["GET"],
    allow_headers=["*"],
)


# ── Helpers ───────────────────────────────────────────────────────────────────

def get_db() -> Session:
    return Session(engine)

def _d(d) -> Optional[str]:
    """Safely stringify a date/datetime."""
    if d is None:
        return None
    return str(d)[:10]


# ── Component metadata ────────────────────────────────────────────────────────

COMPONENT_META = {
    "regulatory":  "ICO enforcement actions, news, consultations",
    "legislative": "Bills, statutory instruments, force dates",
    "political":   "Government speeches, budget signals, Q&A",
    "judicial":    "Court decisions, tribunal outcomes",
    "media":       "NGO activity, press coverage",
    "complaint":   "ICO complaint volume trends by sector",
}


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 1 — ENFORCEMENT RISK SCORE
# ══════════════════════════════════════════════════════════════════════════════

class ComponentDetail(BaseModel):
    component: str
    description: str
    weight: float
    normalised_score: float
    signal_count: Optional[int] = None
    top_signals: Optional[list] = None

class ScoreResponse(BaseModel):
    entity_type: str
    entity_id: str
    ers_score: float
    ers_band: str
    score_low: int
    score_high: int
    weight_version: str
    data_completeness: float
    components: list[ComponentDetail]
    window_days: int
    window_end: Optional[str]
    computed_at: str
    source: str   # "cached" | "live"


@app.get("/api/v1/score", response_model=ScoreResponse, tags=["Score"])
def get_score(
    entity_type:    str  = Query("sector"),
    entity_id:      str  = Query("Information Technology"),
    window_days:    int  = Query(90),
    weight_version: str  = Query("v1_equal"),
    live:           bool = Query(False, description="Force live recompute, bypassing cache"),
):
    """
    Returns the ERS for one entity.

    Normal flow:
      1. Look up the latest pre-computed score from ers_composite_scores
         (written by running `python ers_scoring.py`).
      2. If found, return it with per-component breakdown from ers_component_scores.
      3. If not found (or live=true), call compute_ers() directly and return live result.

    After you run the calibration notebook and settle on weights, change the
    ERSWeights() call in the live-compute fallback to use your calibrated weights.
    """
    db = get_db()

    # ── Try cache first ───────────────────────────────────────────────────────
    if not live:
        cached = (
            db.query(ERSCompositeScore)
            .filter_by(
                entity_type=entity_type,
                entity_id=entity_id,
                window_days=window_days,
                weight_version=weight_version,
            )
            .order_by(desc(ERSCompositeScore.computed_at))
            .first()
        )

        if cached:
            # Pull component detail rows (written by save_component_score in ers_scoring.py)
            comp_rows = (
                db.query(ERSComponentScore)
                .filter_by(
                    entity_type=entity_type,
                    entity_id=entity_id,
                    window_days=window_days,
                    window_end=cached.window_end,
                )
                .all()
            )
            db.close()

            comp_lookup = {r.component: r for r in comp_rows}
            weights_map = {
                "regulatory":  cached.w_regulatory  or 0.0,
                "legislative": cached.w_legislative or 0.0,
                "political":   cached.w_political   or 0.0,
                "judicial":    cached.w_judicial    or 0.0,
                "media":       cached.w_media       or 0.0,
                "complaint":   cached.w_complaint   or 0.0,
            }
            scores_map = {
                "regulatory":  cached.regulatory_score  or 0.0,
                "legislative": cached.legislative_score or 0.0,
                "political":   cached.political_score   or 0.0,
                "judicial":    cached.judicial_score    or 0.0,
                "media":       cached.media_score       or 0.0,
                "complaint":   cached.complaint_score   or 0.0,
            }

            components = []
            for comp, desc_text in COMPONENT_META.items():
                cr = comp_lookup.get(comp)
                try:
                    top = json.loads(cr.top_signals) if cr and cr.top_signals else []
                except Exception:
                    top = []
                components.append(ComponentDetail(
                    component=comp,
                    description=desc_text,
                    weight=weights_map[comp],
                    normalised_score=scores_map[comp],
                    signal_count=cr.signal_count if cr else None,
                    top_signals=top,
                ))

            score = cached.ers_score
            margin = max(5, int(score * 0.10))
            return ScoreResponse(
                entity_type=entity_type,
                entity_id=entity_id,
                ers_score=score,
                ers_band=cached.ers_band,
                score_low=max(0,   int(score) - margin),
                score_high=min(100, int(score) + margin),
                weight_version=cached.weight_version,
                data_completeness=cached.data_completeness or 0.0,
                components=components,
                window_days=cached.window_days,
                window_end=_d(cached.window_end),
                computed_at=cached.computed_at.isoformat() if cached.computed_at else "",
                source="cached",
            )

    db.close()

    # ── Live fallback ─────────────────────────────────────────────────────────
    # TODO: swap ERSWeights() for your calibrated weights once the notebook is done.
    # e.g. weights = ERSWeights(regulatory=0.30, legislative=0.25, ..., version="v2_calibrated")
    weights = ERSWeights()
    composite = compute_ers(entity_type, entity_id, weights, window_days)

    score = composite.ers_score
    margin = max(5, int(score * 0.10))
    w = weights.as_dict()
    norm = {
        "regulatory":  composite.regulatory_score  or 0.0,
        "legislative": composite.legislative_score or 0.0,
        "political":   composite.political_score   or 0.0,
        "judicial":    composite.judicial_score    or 0.0,
        "media":       composite.media_score       or 0.0,
        "complaint":   composite.complaint_score   or 0.0,
    }
    components = [
        ComponentDetail(
            component=comp,
            description=desc_text,
            weight=w[comp],
            normalised_score=norm[comp],
        )
        for comp, desc_text in COMPONENT_META.items()
    ]

    return ScoreResponse(
        entity_type=entity_type,
        entity_id=entity_id,
        ers_score=score,
        ers_band=composite.ers_band,
        score_low=max(0,   int(score) - margin),
        score_high=min(100, int(score) + margin),
        weight_version=weights.version,
        data_completeness=composite.data_completeness or 0.0,
        components=components,
        window_days=window_days,
        window_end=_d(composite.window_end),
        computed_at=datetime.now(timezone.utc).isoformat(),
        source="live",
    )


@app.get("/api/v1/scores/all-sectors", tags=["Score"])
def get_all_sector_scores(
    window_days:    int = Query(90),
    weight_version: str = Query("v1_equal"),
):
    """Latest ERS for every sector — used for the sector rankings / heatmap view."""
    db = get_db()
    rows = []
    for sector in DEFAULT_SECTORS:
        cached = (
            db.query(ERSCompositeScore)
            .filter_by(
                entity_type="sector",
                entity_id=sector,
                window_days=window_days,
                weight_version=weight_version,
            )
            .order_by(desc(ERSCompositeScore.computed_at))
            .first()
        )
        if cached:
            rows.append({
                "entity_id":        sector,
                "ers_score":        cached.ers_score,
                "ers_band":         cached.ers_band,
                "data_completeness": cached.data_completeness,
                "window_end":       _d(cached.window_end),
            })
    db.close()
    rows.sort(key=lambda r: r["ers_score"], reverse=True)
    return rows


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 2 — LIVE ALERTS
# ══════════════════════════════════════════════════════════════════════════════

class Alert(BaseModel):
    severity: str
    title: str
    date: Optional[str]
    source_category: str
    source_url: Optional[str]


@app.get("/api/v1/alerts", response_model=list[Alert], tags=["Alerts"])
def get_alerts(limit: int = Query(10, le=50)):
    db = get_db()
    alerts: list[Alert] = []
    today = date.today()

    for row in (
        db.query(R1EnforcementRegister)
        .filter(R1EnforcementRegister.severity_tier.in_(["Critical", "High"]))
        .order_by(desc(R1EnforcementRegister.action_date))
        .limit(4)
    ):
        alerts.append(Alert(
            severity="Critical" if row.severity_tier == "Critical" else "Elevated",
            title=f"{row.action_type} opened — {row.org_name[:70]}",
            date=_d(row.action_date),
            source_category="Regulatory",
            source_url=row.source_url,
        ))

    for row in (
        db.query(L2StatutoryInstrument)
        .filter(
            L2StatutoryInstrument.relevance_score >= 0.7,
            L2StatutoryInstrument.si_status.in_(["Made", "In Force"]),
        )
        .order_by(desc(L2StatutoryInstrument.laid_date))
        .limit(2)
    ):
        alerts.append(Alert(
            severity="Critical",
            title=f"{row.si_number} laid — commencement order confirmed {_d(row.force_date)} force date",
            date=_d(row.laid_date or row.made_date),
            source_category="Legislative",
            source_url=row.source_url,
        ))

    for row in (
        db.query(R3IcoConsultations)
        .filter(
            R3IcoConsultations.consultation_closes >= today,
            R3IcoConsultations.topic_relevance_score >= 0.6,
        )
        .order_by(R3IcoConsultations.consultation_closes)
        .limit(2)
    ):
        days_left = (row.consultation_closes - today).days
        alerts.append(Alert(
            severity="Elevated" if days_left <= 30 else "Watch",
            title=f"{row.title[:80]} — consultation closes {_d(row.consultation_closes)}",
            date=_d(row.consultation_closes),
            source_category="Regulatory",
            source_url=row.source_url,
        ))

    for row in (
        db.query(M1NgoActivity)
        .filter(
            M1NgoActivity.formal_complaint == True,
            M1NgoActivity.topic_relevance_score >= 0.6,
        )
        .order_by(desc(M1NgoActivity.publication_date))
        .limit(3)
    ):
        alerts.append(Alert(
            severity="Elevated",
            title=f"{row.ngo_name} files formal ICO complaint — {str(row.title)[:60]}",
            date=_d(row.publication_date),
            source_category="Media & Civil Society",
            source_url=row.source_url,
        ))

    db.close()
    alerts.sort(key=lambda a: a.date or "", reverse=True)
    return alerts[:limit]


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 3 — SIGNAL SOURCES
# ══════════════════════════════════════════════════════════════════════════════

class SignalSource(BaseModel):
    id: str
    title: str
    date: Optional[str]
    source_category: str
    content_type: str
    summary: str
    enforcement_signal: Optional[float]
    source_url: Optional[str]
    relevance_score: Optional[float]


@app.get("/api/v1/signals", response_model=list[SignalSource], tags=["Signals"])
def get_signals(
    category: Optional[str] = Query(None),
    limit: int = Query(20, le=100),
):
    db = get_db()
    signals: list[SignalSource] = []

    if not category or category == "Legislative":
        for row in db.query(L2StatutoryInstrument).filter(
            L2StatutoryInstrument.relevance_score >= 0.5
        ).order_by(desc(L2StatutoryInstrument.laid_date)).limit(5):
            signals.append(SignalSource(
                id=row.si_id, title=f"{row.si_number} — {row.si_title}",
                date=_d(row.laid_date or row.made_date),
                source_category="Legislative", content_type="Statutory instrument",
                summary=row.provisions_commenced or row.relevance_tag or "",
                enforcement_signal=None, source_url=row.source_url,
                relevance_score=row.relevance_score,
            ))
        for row in db.query(L1Bill).filter(
            L1Bill.bill_status == "Active", L1Bill.relevance_score >= 0.6,
        ).order_by(desc(L1Bill.event_date)).limit(3):
            signals.append(SignalSource(
                id=row.bill_id, title=row.bill_title,
                date=_d(row.event_date),
                source_category="Legislative", content_type="Act of Parliament",
                summary=row.relevance_tag or "",
                enforcement_signal=None, source_url=row.source_url,
                relevance_score=row.relevance_score,
            ))

    if not category or category == "Regulatory":
        for row in db.query(R1EnforcementRegister).order_by(
            desc(R1EnforcementRegister.action_date)
        ).limit(6):
            signals.append(SignalSource(
                id=row.enforcement_id, title=f"{row.action_type} — {row.org_name}",
                date=_d(row.action_date),
                source_category="Regulatory", content_type="ICO enforcement register",
                summary=row.raw_summary or "",
                enforcement_signal=row.enforcement_signal,
                source_url=row.source_url, relevance_score=None,
            ))
        for row in db.query(R2IcoNews).filter(
            R2IcoNews.topic_relevance_score >= 0.5
        ).order_by(desc(R2IcoNews.publication_date)).limit(5):
            signals.append(SignalSource(
                id=row.news_id, title=row.title,
                date=_d(row.publication_date),
                source_category="Regulatory", content_type=row.content_type,
                summary="",
                enforcement_signal=row.enforcement_signal,
                source_url=row.source_url, relevance_score=row.topic_relevance_score,
            ))

    if not category or category == "Political":
        for row in db.query(P1GovernmentSpeeches).filter(
            P1GovernmentSpeeches.topic_relevance_score >= 0.5,
        ).order_by(desc(P1GovernmentSpeeches.speech_date)).limit(5):
            signals.append(SignalSource(
                id=row.speech_id, title=row.title,
                date=_d(row.speech_date),
                source_category="Political", content_type="Government speech",
                summary=f"{row.speaker_name}, {row.department}" if row.speaker_name else row.department,
                enforcement_signal=row.enforcement_signal,
                source_url=row.speech_url, relevance_score=row.topic_relevance_score,
            ))
        for row in db.query(P3BudgetDocuments).filter(
            P3BudgetDocuments.ico_budget_flag == True,
        ).order_by(desc(P3BudgetDocuments.budget_date)).limit(3):
            signals.append(SignalSource(
                id=row.budget_id, title=row.item_description[:120],
                date=_d(row.budget_date),
                source_category="Political", content_type="Budget document",
                summary=f"£{row.amount_gbp:,.0f} | YoY: {row.yoy_direction}" if row.amount_gbp else "",
                enforcement_signal=row.enforcement_signal,
                source_url=row.source_url, relevance_score=None,
            ))

    if not category or category == "Judicial":
        for row in db.query(J3InformationRightsTribunal).order_by(
            desc(J3InformationRightsTribunal.decision_date)
        ).limit(4):
            signals.append(SignalSource(
                id=row.tribunal_id, title=row.case_reference,
                date=_d(row.decision_date),
                source_category="Judicial", content_type="Information Rights Tribunal",
                summary=row.appeals_ground or "",
                enforcement_signal=row.enforcement_signal,
                source_url=row.case_url, relevance_score=None,
            ))
        for row in db.query(J2CourtOfAppeal).order_by(
            desc(J2CourtOfAppeal.decision_date)
        ).limit(3):
            signals.append(SignalSource(
                id=row.appeal_id, title=row.case_name,
                date=_d(row.decision_date),
                source_category="Judicial", content_type="Court of Appeal",
                summary=row.outcome_summary or "",
                enforcement_signal=row.enforcement_signal,
                source_url=row.case_url, relevance_score=None,
            ))

    if not category or category == "Media & civil society":
        for row in db.query(M1NgoActivity).filter(
            M1NgoActivity.topic_relevance_score >= 0.5,
        ).order_by(desc(M1NgoActivity.publication_date)).limit(5):
            signals.append(SignalSource(
                id=row.ngo_activity_id,
                title=f"{row.ngo_name} — {str(row.title)[:80]}",
                date=_d(row.publication_date),
                source_category="Media & civil society", content_type=row.activity_type,
                summary=row.content_summary or "",
                enforcement_signal=None, source_url=row.source_url,
                relevance_score=row.topic_relevance_score,
            ))
        for row in db.query(M2MediaPress).filter(
            M2MediaPress.topic_relevance_score >= 0.5,
        ).order_by(desc(M2MediaPress.publication_date)).limit(5):
            signals.append(SignalSource(
                id=row.press_id,
                title=f"{row.outlet} — {str(row.headline)[:80]}",
                date=_d(row.publication_date),
                source_category="Media & civil society", content_type=row.story_type,
                summary=row.content_summary or "",
                enforcement_signal=None, source_url=row.source_url,
                relevance_score=row.topic_relevance_score,
            ))

    db.close()
    signals.sort(key=lambda s: s.date or "", reverse=True)
    return signals[:limit]


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 4 — TIMELINE
# ══════════════════════════════════════════════════════════════════════════════

class TimelineEvent(BaseModel):
    date: str
    title: str
    description: str
    status: str
    source_category: str
    source_url: Optional[str]


@app.get("/api/v1/timeline", response_model=list[TimelineEvent], tags=["Timeline"])
def get_timeline():
    db = get_db()
    events: list[TimelineEvent] = []
    today = date.today()

    for row in db.query(L2StatutoryInstrument).filter(
        L2StatutoryInstrument.relevance_score >= 0.6,
        L2StatutoryInstrument.force_date.isnot(None),
    ).order_by(L2StatutoryInstrument.force_date):
        force = row.force_date
        days_left = (force - today).days
        if force < today:
            status = "Complete"
        elif days_left <= 90:
            status = "Critical"
        elif days_left <= 180:
            status = "Watch"
        else:
            status = "Future"
        events.append(TimelineEvent(
            date=_d(force), title=f"{row.si_number} enters force",
            description=row.provisions_commenced or row.si_title,
            status=status, source_category="Legislative", source_url=row.source_url,
        ))

    for row in db.query(L1Bill).filter(
        L1Bill.relevance_score >= 0.7,
        L1Bill.event_type.in_(["Royal Assent", "Third Reading", "Committee Stage", "Second Reading"]),
    ).order_by(L1Bill.event_date):
        status = "Complete" if row.event_date < today else "Future"
        events.append(TimelineEvent(
            date=_d(row.event_date),
            title=f"{row.bill_title[:60]} — {row.event_type}",
            description=row.relevance_tag or "",
            status=status, source_category="Legislative", source_url=row.source_url,
        ))

    for row in db.query(R3IcoConsultations).filter(
        R3IcoConsultations.topic_relevance_score >= 0.6,
        R3IcoConsultations.consultation_closes.isnot(None),
    ).order_by(R3IcoConsultations.consultation_closes):
        close = row.consultation_closes
        days_left = (close - today).days
        if close < today:
            status = "Complete"
        elif days_left <= 30:
            status = "Critical"
        else:
            status = "Watch"
        events.append(TimelineEvent(
            date=_d(close), title=f"Consultation closes — {row.title[:60]}",
            description=row.key_obligations or "",
            status=status, source_category="Regulatory", source_url=row.source_url,
        ))

    db.close()
    events.sort(key=lambda e: e.date or "")
    return events


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 5 — BUDGET SIGNAL
# ══════════════════════════════════════════════════════════════════════════════

class BudgetSignal(BaseModel):
    budget_year: int
    amount_gbp: Optional[float]
    yoy_change_pct: Optional[float]
    yoy_direction: Optional[str]
    source_url: Optional[str]


@app.get("/api/v1/budget-signal", response_model=BudgetSignal, tags=["Political"])
def get_budget_signal():
    db = get_db()
    row = db.query(P3BudgetDocuments).filter(
        P3BudgetDocuments.ico_budget_flag == True,
    ).order_by(desc(P3BudgetDocuments.budget_year)).first()
    db.close()
    if not row:
        raise HTTPException(status_code=404, detail="No ICO budget record found")
    return BudgetSignal(
        budget_year=row.budget_year,
        amount_gbp=float(row.amount_gbp) if row.amount_gbp else None,
        yoy_change_pct=row.yoy_change_pct,
        yoy_direction=row.yoy_direction,
        source_url=row.source_url,
    )


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 6 — FORCE DATE COUNTDOWN
# ══════════════════════════════════════════════════════════════════════════════

class ForceDate(BaseModel):
    si_number: str
    si_title: str
    force_date: str
    days_until_force: int
    status: str


@app.get("/api/v1/force-date", response_model=ForceDate, tags=["Legislative"])
def get_force_date():
    db = get_db()
    today = date.today()
    row = db.query(L2StatutoryInstrument).filter(
        L2StatutoryInstrument.force_date >= today,
        L2StatutoryInstrument.relevance_score >= 0.6,
        L2StatutoryInstrument.si_status.in_(["Made", "In Force"]),
    ).order_by(L2StatutoryInstrument.force_date).first()
    db.close()
    if not row:
        raise HTTPException(status_code=404, detail="No upcoming force date found")
    days = (row.force_date - today).days
    return ForceDate(
        si_number=row.si_number, si_title=row.si_title,
        force_date=_d(row.force_date),
        days_until_force=days,
        status="Critical" if days <= 90 else "Watch",
    )


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 7 — CALIBRATION STATUS
# Shows the dashboard which weight version is active + when last run.
# ══════════════════════════════════════════════════════════════════════════════

@app.get("/api/v1/calibration-status", tags=["Admin"])
def get_calibration_status():
    df = df_from_query("""
        SELECT weight_version,
               COUNT(*)         AS score_count,
               AVG(ers_score)   AS avg_ers_score,
               MAX(computed_at) AS last_run
        FROM ers_composite_scores
        GROUP BY weight_version
        ORDER BY last_run DESC
    """)
    if df.empty:
        return {
            "versions": [],
            "note": "No scores in ers_composite_scores yet — run: python ers_scoring.py",
        }
    return {"versions": df.to_dict("records")}


# ══════════════════════════════════════════════════════════════════════════════
# SECTION 8 — HEALTH
# ══════════════════════════════════════════════════════════════════════════════

@app.get("/api/v1/health", tags=["Health"])
def health():
    try:
        with Session(engine) as db:
            db.execute(text("SELECT 1"))
        return {"status": "ok", "db": "connected", "timestamp": datetime.now(timezone.utc).isoformat()}
    except Exception as e:
        raise HTTPException(status_code=503, detail=f"DB unreachable: {e}")
