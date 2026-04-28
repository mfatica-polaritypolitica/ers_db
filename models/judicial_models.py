"""
judicial_models.py — Shared models for ERS Judicial Component
=============================================================
Usage:
    from judicial_models import engine, create_tables
    from judicial_models import J1SupremeCourt, J2CourtOfAppeal
    from judicial_models import J3InformationRightsTribunal, J4HighCourt
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

from dotenv import load_dotenv
load_dotenv()

# ── Connection ────────────────────────────────────────────────────────────────

DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://postgres:yourpassword@localhost:5432/ers_db"
)

engine = create_engine(DATABASE_URL, echo=False, future=True)


# ── Base ──────────────────────────────────────────────────────────────────────

class Base(DeclarativeBase):
    pass


# ── J1: UK Supreme Court ──────────────────────────────────────────────────────

class J1SupremeCourt(Base):
    __tablename__ = "j1_supreme_court"

    __table_args__ = (
        CheckConstraint(
            "appellant_type IN ('Data Subject','Controller','Processor','Regulator','Government')",
            name="ck_j1_appellant_type"
        ),
        CheckConstraint(
            "respondent_type IN ('Data Subject','Controller','Processor','Regulator','Government')",
            name="ck_j1_respondent_type"
        ),
        CheckConstraint(
            "ico_role IN ('Party (Appellant)','Party (Respondent)','Intervener','Amicus','None')",
            name="ck_j1_ico_role"
        ),
        CheckConstraint(
            "outcome_direction IN ('Controller','Data Subject','ICO','Mixed','Procedural')",
            name="ck_j1_outcome_direction"
        ),
        CheckConstraint(
            "precedent_weight IN ('Binding','Highly Persuasive','Persuasive')",
            name="ck_j1_precedent_weight"
        ),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1", name="ck_j1_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",     name="ck_j1_nlp_confidence"),
    )

    supreme_id                  = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    case_name                   = Column(String(500), nullable=False)
    neutral_citation            = Column(String(100), unique=True)
    decision_date               = Column(Date, nullable=False, index=True)
    subject_matter              = Column(String(200))
    appellant                   = Column(String(300))
    respondent                  = Column(String(300))
    appellant_type              = Column(String(50), index=True)
    respondent_type             = Column(String(50), index=True)
    ico_role                    = Column(String(30), index=True)
    ico_position_upheld         = Column(Boolean)
    outcome_direction           = Column(String(20), index=True)
    outcome_summary             = Column(Text)
    precedent_weight            = Column(String(30), nullable=False)
    processing_activities       = Column(String(500))
    gdpr_articles               = Column(String(500))
    gdpr_principles             = Column(String(500))
    damages_awarded             = Column(Boolean, default=False)
    damages_amount              = Column(Numeric(15, 2))
    ai_specific                 = Column(Boolean, default=False, index=True)
    widens_controller_liability = Column(Boolean, default=False, index=True)
    restricts_ico_powers        = Column(Boolean, default=False, index=True)
    enforcement_signal          = Column(Float)
    case_url                    = Column(Text)
    ingested_at                 = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence              = Column(Float)
    manually_reviewed           = Column(Boolean, default=False, index=True)

    @property
    def is_ico_win(self) -> bool:
        return self.outcome_direction == "ICO" or self.ico_position_upheld is True

    @property
    def days_since_decision(self) -> int:
        return (date.today() - self.decision_date).days

    def __repr__(self) -> str:
        return f"<J1 {self.case_name} | {self.decision_date} | {self.outcome_direction}>"


# ── J2: Court of Appeal ───────────────────────────────────────────────────────

class J2CourtOfAppeal(Base):
    __tablename__ = "j2_court_of_appeal"

    __table_args__ = (
        CheckConstraint(
            "division IN ('Civil','Criminal')",
            name="ck_j2_division"
        ),
        CheckConstraint(
            "appellant_type IN ('Data Subject','Controller','Processor','Regulator','Government')",
            name="ck_j2_appellant_type"
        ),
        CheckConstraint(
            "respondent_type IN ('Data Subject','Controller','Processor','Regulator','Government')",
            name="ck_j2_respondent_type"
        ),
        CheckConstraint(
            "ico_role IN ('Party (Appellant)','Party (Respondent)','Intervener','Amicus','None')",
            name="ck_j2_ico_role"
        ),
        CheckConstraint(
            "outcome_direction IN ('Controller','Data Subject','ICO','Mixed','Procedural')",
            name="ck_j2_outcome_direction"
        ),
        CheckConstraint(
            "precedent_weight IN ('Binding','Highly Persuasive','Persuasive')",
            name="ck_j2_precedent_weight"
        ),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1", name="ck_j2_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",     name="ck_j2_nlp_confidence"),
    )

    appeal_id                   = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    case_name                   = Column(String(500), nullable=False)
    neutral_citation            = Column(String(100), unique=True)
    decision_date               = Column(Date, nullable=False, index=True)
    division                    = Column(String(20), nullable=False)
    subject_matter              = Column(String(200))
    appellant_type              = Column(String(50), index=True)
    respondent_type             = Column(String(50), index=True)
    ico_role                    = Column(String(30), index=True)
    ico_position_upheld         = Column(Boolean)
    outcome_direction           = Column(String(20), index=True)
    outcome_summary             = Column(Text)
    precedent_weight            = Column(String(30), nullable=False)
    processing_activities       = Column(String(500))
    gdpr_articles               = Column(String(500))
    gdpr_principles             = Column(String(500))
    damages_awarded             = Column(Boolean, default=False)
    damages_amount              = Column(Numeric(15, 2))
    ai_specific                 = Column(Boolean, default=False, index=True)
    widens_controller_liability = Column(Boolean, default=False, index=True)
    restricts_ico_powers        = Column(Boolean, default=False, index=True)
    enforcement_signal          = Column(Float)
    case_url                    = Column(Text)
    ingested_at                 = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence              = Column(Float)
    manually_reviewed           = Column(Boolean, default=False, index=True)

    @property
    def is_ico_win(self) -> bool:
        return self.outcome_direction == "ICO" or self.ico_position_upheld is True

    def __repr__(self) -> str:
        return f"<J2 {self.case_name} | {self.decision_date} | {self.outcome_direction}>"


# ── J3: Information Rights Tribunal ──────────────────────────────────────────

class J3InformationRightsTribunal(Base):
    __tablename__ = "j3_information_rights_tribunal"

    __table_args__ = (
        CheckConstraint(
            "tier IN ('First-tier','Upper Tribunal')",
            name="ck_j3_tier"
        ),
        CheckConstraint(
            """case_type IN (
                'Enforcement Notice Appeal','Monetary Penalty Appeal',
                'Information Notice Appeal','Data Subject Rights Appeal'
            )""",
            name="ck_j3_case_type"
        ),
        CheckConstraint(
            "appellant_type IN ('Controller','Processor','Data Subject','ICO')",
            name="ck_j3_appellant_type"
        ),
        CheckConstraint(
            "ico_role IN ('Respondent','Appellant','None')",
            name="ck_j3_ico_role"
        ),
        CheckConstraint(
            "outcome_direction IN ('Controller','Data Subject','ICO','Mixed','Procedural')",
            name="ck_j3_outcome_direction"
        ),
        CheckConstraint(
            "precedent_weight IN ('Binding','Highly Persuasive','Persuasive')",
            name="ck_j3_precedent_weight"
        ),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1", name="ck_j3_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",     name="ck_j3_nlp_confidence"),
    )

    tribunal_id                 = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    case_reference              = Column(String(100), nullable=False, unique=True)
    tier                        = Column(String(20), nullable=False, index=True)
    decision_date               = Column(Date, nullable=False, index=True)
    case_type                   = Column(String(50), nullable=False, index=True)
    appellant_type              = Column(String(50), index=True)
    ico_role                    = Column(String(20), index=True)
    ico_position_upheld         = Column(Boolean)
    outcome_direction           = Column(String(20), index=True)
    original_penalty_gbp        = Column(Numeric(15, 2))
    revised_penalty_gbp         = Column(Numeric(15, 2))
    penalty_reduction_pct       = Column(Float)
    appeals_ground              = Column(String(500))
    processing_activities       = Column(String(500))
    gdpr_articles               = Column(String(500))
    ai_specific                 = Column(Boolean, default=False, index=True)
    precedent_weight            = Column(String(30))
    enforcement_signal          = Column(Float)
    case_url                    = Column(Text)
    ingested_at                 = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence              = Column(Float)
    manually_reviewed           = Column(Boolean, default=False, index=True)

    @property
    def computed_penalty_reduction_pct(self) -> Optional[float]:
        if self.original_penalty_gbp and self.revised_penalty_gbp:
            orig    = float(self.original_penalty_gbp)
            revised = float(self.revised_penalty_gbp)
            if orig > 0:
                return round((orig - revised) / orig * 100, 2)
        return None

    @property
    def is_ico_win(self) -> bool:
        return self.outcome_direction == "ICO" or self.ico_position_upheld is True

    def __repr__(self) -> str:
        return f"<J3 {self.case_reference} | {self.case_type} | {self.outcome_direction}>"


# ── J4: High Court ────────────────────────────────────────────────────────────

class J4HighCourt(Base):
    __tablename__ = "j4_high_court"

    __table_args__ = (
        CheckConstraint(
            "division IN ('King''s Bench','Chancery','Family')",
            name="ck_j4_division"
        ),
        CheckConstraint(
            "case_type IN ('Judicial Review','Civil Damages Claim','Injunction','Declaration')",
            name="ck_j4_case_type"
        ),
        CheckConstraint(
            "ico_role IN ('Party (Appellant)','Party (Respondent)','Intervener','Amicus','Defendant','None')",
            name="ck_j4_ico_role"
        ),
        CheckConstraint(
            "outcome_direction IN ('Controller','Data Subject','ICO','Mixed','Procedural')",
            name="ck_j4_outcome_direction"
        ),
        CheckConstraint(
            "precedent_weight IN ('Binding','Highly Persuasive','Persuasive')",
            name="ck_j4_precedent_weight"
        ),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1", name="ck_j4_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",     name="ck_j4_nlp_confidence"),
    )

    highcourt_id                = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    case_name                   = Column(String(500), nullable=False)
    neutral_citation            = Column(String(100), unique=True)
    decision_date               = Column(Date, nullable=False, index=True)
    division                    = Column(String(30), nullable=False)
    case_type                   = Column(String(50), nullable=False, index=True)
    ico_role                    = Column(String(20), index=True)
    ico_position_upheld         = Column(Boolean)
    jr_permission_granted       = Column(Boolean)
    outcome_direction           = Column(String(20), index=True)
    outcome_summary             = Column(Text)
    precedent_weight            = Column(String(30), nullable=False)
    processing_activities       = Column(String(500))
    gdpr_articles               = Column(String(500))
    gdpr_principles             = Column(String(500))
    damages_awarded             = Column(Boolean, default=False)
    damages_amount              = Column(Numeric(15, 2))
    ai_specific                 = Column(Boolean, default=False, index=True)
    widens_controller_liability = Column(Boolean, default=False, index=True)
    restricts_ico_powers        = Column(Boolean, default=False, index=True)
    enforcement_signal          = Column(Float)
    case_url                    = Column(Text)
    ingested_at                 = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence              = Column(Float)
    manually_reviewed           = Column(Boolean, default=False, index=True)

    @property
    def is_ico_win(self) -> bool:
        return self.outcome_direction == "ICO" or self.ico_position_upheld is True

    def __repr__(self) -> str:
        return f"<J4 {self.case_name} | {self.division} | {self.outcome_direction}>"


# ── Create tables ─────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    print("✓ Tables ready: j1_supreme_court, j2_court_of_appeal,")
    print("                j3_information_rights_tribunal, j4_high_court")


if __name__ == "__main__":
    create_tables()
