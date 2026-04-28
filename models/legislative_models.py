"""
models.py — Shared models for ERS Legislative Component
========================================================
Import this in any script that needs to read from or write
to the legislative tables.

Usage:
    from models import engine, Base, L1Bill, L2StatutoryInstrument
"""

import os
import uuid
from datetime import date, datetime, timezone
from typing import Optional

from sqlalchemy import (
    Boolean, CheckConstraint, Column, Date, Float,
    ForeignKey, Integer, String, Text, create_engine
)
from sqlalchemy import TIMESTAMP
from sqlalchemy.orm import DeclarativeBase, Session, relationship


# ── Connection ────────────────────────────────────────────────────────────────
from dotenv import load_dotenv
load_dotenv()

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:yourpassword@localhost:5432/ers_db"  # <- update or set env var
)

engine = create_engine(DATABASE_URL, echo=False, future=True)


# ── Base ──────────────────────────────────────────────────────────────────────

class Base(DeclarativeBase):
    pass


# ── L1: Bills in Parliament ───────────────────────────────────────────────────

class L1Bill(Base):
    __tablename__ = "l1_bills_in_parliament"

    __table_args__ = (
        CheckConstraint(
            "bill_type IN ('Government','Private Members','Hybrid','Private')",
            name="ck_l1_bill_type"
        ),
        CheckConstraint(
            """event_type IN (
                'Introduced','First Reading','Second Reading',
                'Committee Stage','Report Stage','Third Reading',
                'Lords Introduction','Lords Amendments',
                'Ping Pong','Royal Assent','Withdrawal','Lapse'
            )""",
            name="ck_l1_event_type"
        ),
        CheckConstraint("house IN ('Commons','Lords','Both')", name="ck_l1_house"),
        CheckConstraint(
            "bill_status IN ('Active','Passed','Withdrawn','Lapsed')",
            name="ck_l1_bill_status"
        ),
        CheckConstraint(
            "obligation_direction IN ('Increases','Decreases','Clarifies','Mixed')",
            name="ck_l1_obligation_direction"
        ),
        CheckConstraint("relevance_score BETWEEN 0 AND 1", name="ck_l1_relevance_score"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",  name="ck_l1_nlp_confidence"),
    )

    bill_id                 = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    parliament_bill_id      = Column(String(50),  nullable=False, index=True)
    bill_type               = Column(String(50),  nullable=False)
    bill_title              = Column(String(500), nullable=False)
    session                 = Column(String(20),  nullable=False)
    event_type              = Column(String(100), nullable=False)
    event_date              = Column(Date,         nullable=False, index=True)
    house                   = Column(String(10),  nullable=False)
    bill_stage_numeric      = Column(Integer,      nullable=False)
    bill_status             = Column(String(20),  nullable=False, index=True)
    expected_commencement   = Column(Date)
    processing_activities   = Column(String(500))
    relevance_score         = Column(Float,        index=True)
    relevance_tag           = Column(String(500))
    nlp_confidence          = Column(Float)
    obligation_direction    = Column(String(20))
    affects_ico             = Column(Boolean, default=False, index=True)
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    manually_reviewed       = Column(Boolean, default=False, index=True)
    statutory_instruments   = relationship("L2StatutoryInstrument", back_populates="parent_act")

    @property
    def days_to_commencement(self) -> Optional[int]:
        if self.expected_commencement:
            return (self.expected_commencement - date.today()).days
        return None

    @property
    def is_high_relevance(self) -> bool:
        return self.relevance_score is not None and self.relevance_score >= 0.7

    def __repr__(self) -> str:
        return f"<L1Bill {self.parliament_bill_id} | {self.event_type} | {self.event_date}>"


# ── L2: Statutory Instruments ─────────────────────────────────────────────────

class L2StatutoryInstrument(Base):
    __tablename__ = "l2_statutory_instruments"

    __table_args__ = (
        CheckConstraint(
            "si_type IN ('Commencement Order','Amendment SI','Regulatory Reform Order','Other')",
            name="ck_l2_si_type"
        ),
        CheckConstraint(
            "si_status IN ('Made','In Force','Revoked','Amended')",
            name="ck_l2_si_status"
        ),
        CheckConstraint(
            "obligation_type IN ('New Duty','Removal of Exemption','New ICO Power','Penalty Uplift','Other')",
            name="ck_l2_obligation_type"
        ),
        CheckConstraint("relevance_score BETWEEN 0 AND 1", name="ck_l2_relevance_score"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",  name="ck_l2_nlp_confidence"),
    )

    si_id                   = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    si_number               = Column(String(50),  nullable=False, unique=True)
    si_title                = Column(String(500), nullable=False)
    si_type                 = Column(String(100), nullable=False)
    parent_act_id           = Column(
                                String(36),
                                ForeignKey("l1_bills_in_parliament.bill_id", ondelete="SET NULL"),
                                nullable=True,
                                index=True
                              )
    parent_act_name         = Column(String(500))
    made_date               = Column(Date)
    laid_date               = Column(Date)
    force_date              = Column(Date, index=True)
    provisions_commenced    = Column(Text)
    si_status               = Column(String(20), index=True)
    processing_activities   = Column(String(500))
    relevance_score         = Column(Float, index=True)
    relevance_tag           = Column(String(500))
    nlp_confidence          = Column(Float)
    obligation_type         = Column(String(100))
    affects_ico             = Column(Boolean, default=False, index=True)
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    manually_reviewed       = Column(Boolean, default=False, index=True)
    parent_act              = relationship("L1Bill", back_populates="statutory_instruments")

    @property
    def days_to_force(self) -> Optional[int]:
        if self.made_date and self.force_date:
            return (self.force_date - self.made_date).days
        return None

    @property
    def days_until_force(self) -> Optional[int]:
        if self.force_date:
            return (self.force_date - date.today()).days
        return None

    @property
    def is_imminent(self) -> bool:
        d = self.days_until_force
        return d is not None and 0 <= d <= 90

    def __repr__(self) -> str:
        return f"<L2SI {self.si_number} | force={self.force_date} | days_to_force={self.days_to_force}>"


# ── Create tables ─────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    print("✓ Tables ready: l1_bills_in_parliament, l2_statutory_instruments")


if __name__ == "__main__":
    create_tables()
