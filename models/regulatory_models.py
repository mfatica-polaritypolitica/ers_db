"""
regulatory_models.py — Shared models for ERS Regulatory Component
==================================================================
Import this in any script that needs to read from or write
to the regulatory tables.

Usage:
    from regulatory_models import engine, create_tables
    from regulatory_models import R1EnforcementRegister, R2IcoNews, R3IcoConsultations
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
from sqlalchemy.orm import DeclarativeBase, Session


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


# ── R1: ICO Enforcement Register ──────────────────────────────────────────────

class R1EnforcementRegister(Base):
    __tablename__ = "r1_enforcement_register"

    __table_args__ = (
        CheckConstraint(
            "org_size IN ('Micro', 'Small', 'Medium', 'Large')",
            name="ck_r1_org_size"
        ),
        CheckConstraint(
            """action_type IN (
                'Monetary Penalty Notice', 'Enforcement Notice',
                'Information Notice', 'Assessment Notice', 'Undertaking',
                'Reprimand', 'Warning', 'Prosecution',
                'Stop Processing Order', 'Advisory Visit'
            )""",
            name="ck_r1_action_type"
        ),
        CheckConstraint(
            "outcome IN ('Upheld', 'Overturned on Appeal', 'Settled', 'Withdrawn')",
            name="ck_r1_outcome"
        ),
        CheckConstraint(
            "severity_tier IN ('Critical', 'High', 'Medium', 'Low', 'Advisory')",
            name="ck_r1_severity_tier"
        ),
        CheckConstraint(
            "penalty_as_max BETWEEN 0 AND 1",
            name="ck_r1_penalty_as_max"
        ),
        CheckConstraint(
            "nlp_confidence BETWEEN 0 AND 1",
            name="ck_r1_nlp_confidence"
        ),
    )

    enforcement_id          = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    ico_reference           = Column(String(100), unique=True)
    org_name                = Column(String(500), nullable=False)
    org_type                = Column(String(100), nullable=False)
    org_size                = Column(String(10))
    action_date             = Column(Date, nullable=False, index=True)
    action_type             = Column(String(100), nullable=False, index=True)
    outcome                 = Column(String(30))
    penalty_gbp             = Column(Numeric(15, 2))
    penalty_as_max          = Column(Float)
    severity_tier           = Column(String(20), index=True)
    aggravating_factors     = Column(String(500))
    mitigating_factors      = Column(String(500))
    appealed                = Column(Boolean, default=False)
    appeal_outcome          = Column(String(20))
    processing_activities   = Column(String(500))
    legislation_breached    = Column(String(500))
    gdpr_principles         = Column(String(500))
    special_category_data   = Column(Boolean, default=False)
    cross_border            = Column(Boolean, default=False)
    ai_specific             = Column(Boolean, default=False, index=True)
    prior_ico_contact       = Column(Boolean, default=False)
    prior_contact_types     = Column(String(500))
    prior_contact_count     = Column(Integer)
    days_prior_contact      = Column(Integer)
    org_type_recidivism_rate = Column(Float)
    enforcement_signal      = Column(Float)
    nlp_confidence          = Column(Float)
    source_url              = Column(Text)
    raw_summary             = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def penalty_gbp_millions(self) -> Optional[float]:
        if self.penalty_gbp:
            return round(float(self.penalty_gbp) / 1_000_000, 3)
        return None

    def __repr__(self) -> str:
        return f"<R1 {self.org_name} | {self.action_type} | £{self.penalty_gbp}>"


# ── R2: ICO News and Blog ─────────────────────────────────────────────────────

class R2IcoNews(Base):
    __tablename__ = "r2_ico_news"

    __table_args__ = (
        CheckConstraint(
            """content_type IN (
                'News', 'Blog', 'Press Release',
                'Statement', 'Investigation Announcement'
            )""",
            name="ck_r2_content_type"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_r2_relevance"),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1",    name="ck_r2_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_r2_nlp_confidence"),
    )

    news_id                 = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title                   = Column(String(500), nullable=False)
    publication_date        = Column(Date, nullable=False, index=True)
    content_type            = Column(String(50), nullable=False)
    processing_activities   = Column(String(500))
    topic_tags              = Column(String(500))
    topic_relevance_score   = Column(Float, index=True)
    signal_investigation    = Column(Boolean, default=False)
    signal_consultation     = Column(Boolean, default=False)
    enforcement_signal      = Column(Float)
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    raw_text                = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    def __repr__(self) -> str:
        return f"<R2 {self.content_type} | {self.publication_date} | {self.title[:60]}>"


# ── R3: ICO Consultations and Guidance ───────────────────────────────────────

class R3IcoConsultations(Base):
    __tablename__ = "r3_ico_consultations"

    __table_args__ = (
        CheckConstraint(
            """document_type IN (
                'Consultation', 'Guidance', 'Audit Framework',
                'Call for Evidence', 'Opinion', 'Code of Practice'
            )""",
            name="ck_r3_document_type"
        ),
        CheckConstraint(
            "consultation_status IN ('Open', 'Closed', 'Response Published', 'Finalised')",
            name="ck_r3_consultation_status"
        ),
        CheckConstraint(
            "obligation_direction IN ('Tightens', 'Relaxes', 'Clarifies', 'Mixed')",
            name="ck_r3_obligation_direction"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_r3_relevance"),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1",    name="ck_r3_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_r3_nlp_confidence"),
    )

    consultation_id         = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    title                   = Column(String(500), nullable=False)
    publication_date        = Column(Date, nullable=False, index=True)
    document_type           = Column(String(50), nullable=False)
    consultation_status     = Column(String(30), index=True)
    consultation_closes     = Column(Date)
    processing_activities   = Column(String(500))
    topic_tags              = Column(String(500))
    topic_relevance_score   = Column(Float, index=True)
    obligation_direction    = Column(String(20))
    enforcement_signal      = Column(Float)
    follows_enforcement     = Column(Boolean, default=False)
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    raw_text                = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def days_until_closes(self) -> Optional[int]:
        if self.consultation_closes:
            return (self.consultation_closes - date.today()).days
        return None

    def __repr__(self) -> str:
        return f"<R3 {self.document_type} | {self.consultation_status} | {self.title[:60]}>"


# ── R4: Secondary Regulators ──────────────────────────────────────────────────
# Tracks enforcement actions, investigations, and guidance from UK regulators
# that co-regulate the same organisations as the ICO:
#   Competition and Markets Authority (CMA)
#   Ofcom
#   Financial Conduct Authority (FCA)
#   AI Safety Institute (AISI)
#
# Sources:
#   CMA  — cma.gov.uk/cases (HTML) + api.companieshouse.gov.uk
#   Ofcom — ofcom.org.uk/about-ofcom/latest/media (RSS)
#   FCA  — fca.org.uk/news/rss.xml (RSS)
#   AISI — gov.uk content API (same as P1 speeches)

class R4SecondaryRegulators(Base):
    __tablename__ = "r4_secondary_regulators"

    __table_args__ = (
        CheckConstraint(
            "regulator IN ('CMA', 'Ofcom', 'FCA', 'AI Safety Institute', 'Other')",
            name="ck_r4_regulator"
        ),
        CheckConstraint(
            """action_type IN (
                'Enforcement', 'Investigation', 'Guidance',
                'Market Study', 'Statement', 'Fine', 'Undertaking'
            )""",
            name="ck_r4_action_type"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_r4_relevance"),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1",    name="ck_r4_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_r4_nlp_confidence"),
    )

    secondary_id            = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    regulator               = Column(String(50),  nullable=False, index=True)
    action_date             = Column(Date,         nullable=False, index=True)
    action_type             = Column(String(50),   nullable=False, index=True)
    title                   = Column(String(500),  nullable=False)
    org_name                = Column(String(500))                       # organisation subject to action, if applicable
    org_type                = Column(String(100))                       # sector classification
    processing_activities   = Column(String(500))                       # data processing activities referenced
    topic_tags              = Column(String(500))
    topic_relevance_score   = Column(Float,        index=True)
    cross_regulator_flag    = Column(Boolean, default=False, index=True)  # explicitly references/involves the ICO
    ico_referral            = Column(Boolean, default=False, index=True)  # regulator has referred matter to ICO
    enforcement_signal      = Column(Float)                             # composite NLP enforcement intent score (0–1)
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    raw_text                = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def is_ico_relevant(self) -> bool:
        return self.cross_regulator_flag or self.ico_referral

    def __repr__(self) -> str:
        return f"<R4 {self.regulator} | {self.action_type} | {self.action_date}>"


# ── R5: EU and International Regulatory Bodies ────────────────────────────────
# Tracks enforcement decisions and opinions from overseas data regulators.
# Post-Brexit, UK GDPR mirrors EU GDPR, so EU decisions directly inform
# how the ICO will interpret and apply UK law.
#
# Primary bodies:
#   European Data Protection Board (EDPB)
#   Irish Data Protection Commission (DPC) — handles most Big Tech cases
#   French CNIL, German BfDI, Spanish AEPD, Dutch AP
#
# Best single source: GDPR Enforcement Tracker API (gdprenforcement.eu)
# which provides structured data across all EU DPAs in one feed.
# Individual body RSS feeds available as fallback.

class R5InternationalBodies(Base):
    __tablename__ = "r5_international_bodies"

    __table_args__ = (
        CheckConstraint(
            """body IN (
                'EDPB', 'Irish DPC', 'French CNIL', 'German BfDI',
                'Spanish AEPD', 'Dutch AP', 'Italian Garante',
                'Polish UODO', 'Other'
            )""",
            name="ck_r5_body"
        ),
        CheckConstraint(
            """action_type IN (
                'Enforcement Decision', 'Binding Opinion', 'Guideline',
                'Joint Investigation', 'Urgency Procedure', 'Fine', 'Other'
            )""",
            name="ck_r5_action_type"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1",  name="ck_r5_relevance"),
        CheckConstraint("ico_signal_strength BETWEEN 0 AND 1",    name="ck_r5_ico_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",         name="ck_r5_nlp_confidence"),
    )

    international_id        = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    body                    = Column(String(50),  nullable=False, index=True)
    jurisdiction            = Column(String(100), nullable=False)           # country or 'EU'
    action_date             = Column(Date,         nullable=False, index=True)
    action_type             = Column(String(50),   nullable=False, index=True)
    title                   = Column(String(500),  nullable=False)
    org_name                = Column(String(500))                            # organisation subject to action
    org_type                = Column(String(100))                            # sector classification
    penalty_eur             = Column(Numeric(15, 2))                         # fine amount in EUR if applicable
    processing_activities   = Column(String(500))
    topic_tags              = Column(String(500))
    topic_relevance_score   = Column(Float,        index=True)
    uk_company_involved     = Column(Boolean, default=False, index=True)     # company also operating in UK
    gdpr_articles           = Column(String(500))                            # EU GDPR articles engaged
    ico_signal_strength     = Column(Float)                                  # estimated probability of ICO follow-up (0–1)
    source_url              = Column(Text)
    gdpr_tracker_id         = Column(String(100), unique=True)               # GDPR Enforcement Tracker record ID
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def penalty_eur_millions(self) -> Optional[float]:
        if self.penalty_eur:
            return round(float(self.penalty_eur) / 1_000_000, 3)
        return None

    @property
    def is_high_signal(self) -> bool:
        return (self.uk_company_involved or self.ico_signal_strength is not None) and \
               (self.ico_signal_strength or 0) >= 0.5

    def __repr__(self) -> str:
        return f"<R5 {self.body} | {self.action_type} | {self.action_date} | €{self.penalty_eur}>"


# ── R6: Digital Regulation Cooperation Forum (DRCF) ──────────────────────────
# Tracks publications and statements from the DRCF — the joint body of
# ICO, CMA, Ofcom and FCA. DRCF joint statements are strong leading
# indicators of coordinated cross-regulator enforcement.
#
# Source: drcf.org.uk (HTML scraper + RSS if available)
# Volume: low (a few publications per year) but signal quality very high.

class R6DRCF(Base):
    __tablename__ = "r6_drcf"

    __table_args__ = (
        CheckConstraint(
            """document_type IN (
                'Joint Statement', 'Work Programme', 'Report',
                'Consultation Response', 'Guidance', 'Call for Evidence'
            )""",
            name="ck_r6_document_type"
        ),
        CheckConstraint("topic_relevance_score BETWEEN 0 AND 1", name="ck_r6_relevance"),
        CheckConstraint("enforcement_signal BETWEEN 0 AND 1",    name="ck_r6_enforcement_signal"),
        CheckConstraint("nlp_confidence BETWEEN 0 AND 1",        name="ck_r6_nlp_confidence"),
    )

    drcf_id                 = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    publication_date        = Column(Date,         nullable=False, index=True)
    document_type           = Column(String(50),   nullable=False, index=True)
    title                   = Column(String(500),  nullable=False)
    participating_bodies    = Column(String(300))                           # regulators named in publication
    processing_activities   = Column(String(500))
    topic_tags              = Column(String(500))
    topic_relevance_score   = Column(Float,        index=True)
    ico_lead                = Column(Boolean, default=False, index=True)    # ICO is lead body for this publication
    enforcement_signal      = Column(Float)                                 # composite NLP enforcement intent (0–1)
    coordinated_action_flag = Column(Boolean, default=False, index=True)    # signals coordinated cross-regulator action
    source_url              = Column(Text)
    rss_guid                = Column(String(500), unique=True)
    raw_text                = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    nlp_confidence          = Column(Float)
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def is_coordinated_enforcement(self) -> bool:
        return self.coordinated_action_flag and \
               (self.enforcement_signal is not None and self.enforcement_signal >= 0.5)

    def __repr__(self) -> str:
        return f"<R6 DRCF | {self.document_type} | {self.publication_date} | {self.title[:60]}>"


# ── Create tables ─────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    print("✓ Tables ready: r1_enforcement_register, r2_ico_news, r3_ico_consultations,")
    print("                r4_secondary_regulators, r5_international_bodies, r6_drcf")


if __name__ == "__main__":
    create_tables()
