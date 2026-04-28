"""
political_models.py — Shared models for ERS Political Component
===============================================================
Usage:
    from political_models import engine, create_tables
    from political_models import P1GovernmentSpeeches, P6ParliamentaryQA
"""

import os
import uuid
from datetime import date, datetime, timezone
from typing import Optional

from sqlalchemy import (
    Boolean, CheckConstraint, Column, Date, Float,
    Integer, Numeric, String, Text, create_engine
)
from sqlalchemy import TIMESTAMP
from sqlalchemy.orm import DeclarativeBase


# ── Connection ────────────────────────────────────────────────────────────────
from dotenv import load_dotenv
load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:yourpassword@localhost:5432/ers_db"
)

engine = create_engine(DATABASE_URL, echo=False, future=True)


# ── Base ──────────────────────────────────────────────────────────────────────

class Base(DeclarativeBase):
    pass


# ── P1: Government Speeches ───────────────────────────────────────────────────

class P1GovernmentSpeeches(Base):
    __tablename__ = "p1_government_speeches"

    __table_args__ = (
        CheckConstraint(
            "department IN ('DSIT','Cabinet Office','Home Office','HM Treasury','DCMS','MOJ','Other')",
            name="ck_p1_department"
        ),
        CheckConstraint(
            "priority_level IN ('Primary','Secondary','Peripheral','None')",
            name="ck_p1_priority_level"
        ),
        CheckConstraint(
            "regulatory_stance IN ('Pro-enforcement','Neutral','Deregulatory','Mixed')",
            name="ck_p1_regulatory_stance"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_p1_relevance"),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1",    name="ck_p1_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_p1_nlp_confidence"),
    )

    speech_id               = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title                   = Column(String(500), nullable=False)
    speaker_name            = Column(String(200))
    speaker_role            = Column(String(300))
    party                   = Column(String(100))
    department              = Column(String(100), nullable=False, index=True)
    speech_date             = Column(Date, nullable=False, index=True)
    speech_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    topic_relevance_score   = Column(Float, index=True)
    processing_activities   = Column(String(500))
    relevance_tag           = Column(String(500))
    priority_level          = Column(String(20))
    regulatory_stance       = Column(String(20), index=True)
    enforcement_signal      = Column(Float)
    nlp_confidence          = Column(Float)
    ico_mentioned           = Column(Boolean, default=False)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    raw_text                = Column(Text)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    def __repr__(self) -> str:
        return f"<P1 {self.department} | {self.speech_date} | {self.title[:60]}>"


# ── P2: Party Manifestos ──────────────────────────────────────────────────────

class P2PartyManifestos(Base):
    __tablename__ = "p2_party_manifestos"

    __table_args__ = (
        CheckConstraint(
            "obligation_direction IN ('Increases','Decreases','Clarifies','Mixed')",
            name="ck_p2_obligation_direction"
        ),
        CheckConstraint(
            "priority_level IN ('Primary','Secondary','Peripheral')",
            name="ck_p2_priority_level"
        ),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1", name="ck_p2_nlp_confidence"),
    )

    manifesto_id            = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    party                   = Column(String(100), nullable=False, index=True)
    election_year           = Column(Integer, nullable=False, index=True)
    commitment_text         = Column(Text, nullable=False)
    processing_activities   = Column(String(500))
    topic_tags              = Column(String(500))
    obligation_direction    = Column(String(20))
    priority_level          = Column(String(20))
    governing_party         = Column(Boolean, default=False)
    manifesto_project_id    = Column(String(100))
    source_url              = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    def __repr__(self) -> str:
        return f"<P2 {self.party} | {self.election_year} | {self.commitment_text[:60]}>"


# ── P3: Budget Documents ──────────────────────────────────────────────────────

class P3BudgetDocuments(Base):
    __tablename__ = "p3_budget_documents"

    __table_args__ = (
        CheckConstraint(
            "item_type IN ('ICO Allocation','Tech Regulation Fund','AI Safety Spending','Digital Infrastructure','Enforcement Budget','Other')",
            name="ck_p3_item_type"
        ),
        CheckConstraint(
            "yoy_direction IN ('Increase','Decrease','Flat','New Item')",
            name="ck_p3_yoy_direction"
        ),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1", name="ck_p3_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",     name="ck_p3_nlp_confidence"),
    )

    budget_id               = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    budget_year             = Column(Integer, nullable=False, index=True)
    budget_date             = Column(Date, nullable=False)
    item_type               = Column(String(100), nullable=False, index=True)
    item_description        = Column(Text, nullable=False)
    amount_gbp              = Column(Numeric(15, 2))
    yoy_change_pct          = Column(Float)
    yoy_direction           = Column(String(20))
    ico_budget_flag         = Column(Boolean, default=False, index=True)
    enforcement_signal      = Column(Float)
    source_url              = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    def __repr__(self) -> str:
        return f"<P3 FY{self.budget_year} | {self.item_type} | £{self.amount_gbp}>"


# ── P4: Electoral Signals ─────────────────────────────────────────────────────

class P4ElectoralSignals(Base):
    __tablename__ = "p4_electoral_signals"

    __table_args__ = (
        CheckConstraint("governing_poll_ptc BETWEEN 0 AND 100",     name="ck_p4_governing_poll_ptc"),
        CheckConstraint("opposition_poll_ptc BETWEEN 0 AND 100",    name="ck_p4_opposition_poll_ptc"),
        CheckConstraint("prediction_market_prob BETWEEN 0 AND 1",   name="ck_p4_prediction_market_prob"),
        CheckConstraint("gov_change_12m BETWEEN 0 AND 1",           name="ck_p4_gov_change_12m"),
    )

    electoral_id            = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    record_date             = Column(Date, nullable=False, index=True)
    last_election_date      = Column(Date, nullable=False)
    next_election_due       = Column(Date, nullable=False)
    governing_party         = Column(String(100), nullable=False)
    governing_poll_ptc      = Column(Float)
    opposition_poll_ptc     = Column(Float)
    poll_source             = Column(String(200))
    prediction_market_prob  = Column(Float)
    gov_change_12m          = Column(Float, index=True)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))

    def __repr__(self) -> str:
        return f"<P4 {self.governing_party} | {self.record_date} | change_12m={self.gov_change_12m}>"


# ── P5: X/Social Listening ────────────────────────────────────────────────────

class P5SocialListening(Base):
    __tablename__ = "p5_social_listening"

    __table_args__ = (
        CheckConstraint(
            "account_category IN ('Minister','Shadow Minister','MP','Aide','Party Account','Other')",
            name="ck_p5_account_category"
        ),
        CheckConstraint(
            "priority_level IN ('Primary','Secondary','Peripheral')",
            name="ck_p5_priority_level"
        ),
        CheckConstraint(
            "regulatory_stance IN ('Pro-enforcement','Neutral','Deregulatory','Mixed')",
            name="ck_p5_regulatory_stance"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_p5_relevance"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_p5_nlp_confidence"),
    )

    social_id               = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    platform                = Column(String(50), nullable=False, default="X/Twitter")
    account_handle          = Column(String(200), nullable=False, index=True)
    account_name            = Column(String(200))
    account_category        = Column(String(50), nullable=False, index=True)
    party                   = Column(String(100), index=True)
    party_power             = Column(Boolean, default=False)
    post_date               = Column(TIMESTAMP(timezone=True), nullable=False, index=True)
    post_id_platform        = Column(String(200), unique=True)
    raw_text                = Column(Text)
    processing_activities   = Column(String(500))
    topic_relevance_score   = Column(Float, index=True)
    topic_tags              = Column(String(500))
    priority_level          = Column(String(20))
    regulatory_stance       = Column(String(20), index=True)
    engagement_score        = Column(Integer)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    def __repr__(self) -> str:
        return f"<P5 @{self.account_handle} | {self.post_date} | stance={self.regulatory_stance}>"


# ── P6: Parliamentary Q&A ─────────────────────────────────────────────────────

class P6ParliamentaryQA(Base):
    __tablename__ = "p6_parliamentary_qa"

    __table_args__ = (
        CheckConstraint(
            "question_type IN ('Written','Oral','Urgent')",
            name="ck_p6_question_type"
        ),
        CheckConstraint(
            "priority_level IN ('Primary','Secondary','Peripheral')",
            name="ck_p6_priority_level"
        ),
        CheckConstraint(
            "government_position IN ('Supportive of Enforcement','Neutral','Resistant','Unclear')",
            name="ck_p6_government_position"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_p6_relevance"),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1",    name="ck_p6_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_p6_nlp_confidence"),
    )

    pqa_id                  = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    question_date           = Column(Date, nullable=False, index=True)
    answer_date             = Column(Date, index=True)
    question_type           = Column(String(20), nullable=False)
    asking_mp               = Column(String(200), nullable=False)
    asking_party            = Column(String(100))
    asking_party_gov        = Column(Boolean, default=False)
    answering_minister      = Column(String(200))
    answering_department    = Column(String(200))
    answering_party         = Column(String(100))
    question_text           = Column(Text, nullable=False)
    answer_text             = Column(Text)
    processing_activities   = Column(String(500))
    topic_tags              = Column(String(500))
    topic_relevance_score   = Column(Float, index=True)
    priority_level          = Column(String(20))
    government_position     = Column(String(50))
    ico_mentioned           = Column(Boolean, default=False, index=True)
    enforcement_signal      = Column(Float)
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def days_to_answer(self) -> Optional[int]:
        if self.question_date and self.answer_date:
            return (self.answer_date - self.question_date).days
        return None

    def __repr__(self) -> str:
        return f"<P6 {self.asking_mp} → {self.answering_department} | {self.question_date}>"


# ── Create tables ─────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    print("✓ Tables ready: p1–p6 political tables")


if __name__ == "__main__":
    create_tables()
