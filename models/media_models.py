"""
media_models.py — Shared models for ERS Media and Civil Society Component
=========================================================================
Usage:
    from media_models import engine, create_tables, M1NgoActivity, M2MediaPress
"""

import os
import uuid
from datetime import date, datetime, timezone
from typing import Optional

from sqlalchemy import (
    Boolean, CheckConstraint, Column, Date, Float,
    Integer, String, Text, create_engine
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


# ── M1: NGO Activity ──────────────────────────────────────────────────────────

class M1NgoActivity(Base):
    __tablename__ = "m1_ngo_activity"

    __table_args__ = (
        CheckConstraint(
            """ngo_name IN (
                'Big Brother Watch', 'Privacy International',
                'Open Rights Group', 'Liberty', 'Foxglove',
                'Connected by Data', 'MedConfidential',
                'Ada Lovelace Institute', 'Alan Turing Institute',
                'EDRi', 'The Future Society',
                'AI Whistleblower Initiative',
                'European AI and Society Fund', 'Other'
            )""",
            name="ck_m1_ngo_name"
        ),
        CheckConstraint(
            """activity_type IN (
                'Publication', 'Press Release', 'Formal Complaint',
                'Legal Challenge', 'Parliamentary Submission',
                'Open Letter', 'Report'
            )""",
            name="ck_m1_activity_type"
        ),
        CheckConstraint(
            "enforcement_stance IN ('Pro-enforcement','Neutral','Deregulatory','Mixed')",
            name="ck_m1_enforcement_stance"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_m1_relevance"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_m1_nlp_confidence"),
    )

    ngo_activity_id         = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    ngo_name                = Column(String(200), nullable=False, index=True)
    publication_date        = Column(Date, nullable=False, index=True)
    activity_type           = Column(String(50), nullable=False, index=True)
    title                   = Column(Text, nullable=False)
    source_url              = Column(Text)
    target_org              = Column(String(300))
    ico_named               = Column(Boolean, default=False, index=True)
    formal_complaint        = Column(Boolean, default=False, index=True)
    complaint_ref           = Column(String(100))
    legal_action            = Column(Boolean, default=False, index=True)
    content_summary         = Column(Text)
    processing_activities   = Column(String(500))
    topic_relevance_score   = Column(Float, index=True)
    enforcement_stance      = Column(String(20), index=True)
    gdpr_articles           = Column(String(500))
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def is_high_impact(self) -> bool:
        return (self.formal_complaint or self.legal_action) and \
               (self.topic_relevance_score is not None and self.topic_relevance_score >= 0.7)

    @property
    def days_since_publication(self) -> int:
        return (date.today() - self.publication_date).days

    def __repr__(self) -> str:
        return f"<M1 {self.ngo_name} | {self.activity_type} | {self.publication_date}>"


# ── M2: Media Press ───────────────────────────────────────────────────────────

class M2MediaPress(Base):
    __tablename__ = "m2_media_press"

    __table_args__ = (
        CheckConstraint(
            """outlet IN (
                'The Guardian', 'The Times', 'Financial Times',
                'BBC', 'The Register', 'WIRED UK',
                'Computer Weekly', 'City A.M.', 'Other'
            )""",
            name="ck_m2_outlet"
        ),
        CheckConstraint("outlet_tier IN (1, 2, 3)",              name="ck_m2_outlet_tier"),
        CheckConstraint(
            "story_type IN ('Investigation','Opinion','News','Data Breach','Regulatory Response','Profile')",
            name="ck_m2_story_type"
        ),
        CheckConstraint(
            "enforcement_stance IN ('Pro-enforcement','Neutral','Pro-regulatory','Mixed')",
            name="ck_m2_enforcement_stance"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_m2_relevance"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_m2_nlp_confidence"),
    )

    press_id                = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    publication_date        = Column(Date, nullable=False, index=True)
    outlet                  = Column(String(100), nullable=False, index=True)
    outlet_tier             = Column(Integer, nullable=False)
    headline                = Column(Text, nullable=False)
    source_url              = Column(Text)
    author                  = Column(Text)
    story_type              = Column(String(50), nullable=False, index=True)
    target_org              = Column(String(300))
    ico_mentioned           = Column(Boolean, default=False, index=True)
    ico_action              = Column(Boolean, default=False, index=True)
    content_summary         = Column(Text)
    processing_activities   = Column(String(500))
    topic_relevance_score   = Column(Float, index=True)
    enforcement_stance      = Column(String(20), index=True)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def is_high_impact(self) -> bool:
        return self.outlet_tier == 1 and self.ico_action and \
               (self.topic_relevance_score is not None and self.topic_relevance_score >= 0.7)

    @property
    def days_since_publication(self) -> int:
        return (date.today() - self.publication_date).days

    def __repr__(self) -> str:
        return f"<M2 {self.outlet} | {self.publication_date} | {self.headline[:60]}>"


# ── Create tables ─────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    print("✓ Tables ready: m1_ngo_activity, m2_media_press")


if __name__ == "__main__":
    create_tables()
