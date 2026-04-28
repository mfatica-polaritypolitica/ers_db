"""
ico_volume_models.py — Shared models for ERS ICO Complaint Volume Component
============================================================================
Usage:
    from ico_volume_models import engine, create_tables
    from ico_volume_models import I1VolumeStatistics, I2VolumeScores
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


# ── I1: ICO Volume Statistics ─────────────────────────────────────────────────

class I1VolumeStatistics(Base):
    __tablename__ = "i1_volume_statistics"

    __table_args__ = (
        CheckConstraint(
            "period_type IN ('Annual','Quarterly','FOI Response')",
            name="ck_i1_period_type"
        ),
        CheckConstraint(
            "sector_relevance IN ('Full','Partial','None')",
            name="ck_i1_sector_relevance"
        ),
        CheckConstraint(
            "period_end > period_start",
            name="ck_i1_period_dates"
        ),
        CheckConstraint(
            "complaint_count >= 0",
            name="ck_i1_complaint_count"
        ),
    )

    stat_id                 = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    period_start            = Column(Date, nullable=False, index=True)
    period_end              = Column(Date, nullable=False, index=True)
    period_type             = Column(String(20), nullable=False)
    ico_sector              = Column(String(200), nullable=False)
    sector_relevance        = Column(String(10), nullable=False)
    complaint_count         = Column(Integer, nullable=False)
    data_breach_count       = Column(Integer)
    complaint_resolved      = Column(Boolean)
    complaint_resolved_pct  = Column(Float)
    yoy_change_pct          = Column(Float)
    qoq_change_pct          = Column(Float)
    avg_3period             = Column(Float)
    pct_above_avg           = Column(Float)
    spike_flag              = Column(Boolean)
    source_doc              = Column(Text)
    source_url              = Column(Text)
    ingested_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))
    manually_reviewed       = Column(Boolean, default=False, index=True)

    @property
    def computed_spike_flag(self) -> Optional[bool]:
        if self.complaint_count is not None and self.avg_3period and self.avg_3period > 0:
            return self.complaint_count > 1.5 * self.avg_3period
        return None

    @property
    def computed_pct_above_avg(self) -> Optional[float]:
        if self.complaint_count is not None and self.avg_3period and self.avg_3period > 0:
            return round((self.complaint_count / self.avg_3period - 1) * 100, 2)
        return None

    @property
    def period_label(self) -> str:
        if self.period_type == "Annual":
            return f"FY {self.period_start.year}/{str(self.period_end.year)[2:]}"
        elif self.period_type == "Quarterly":
            q = (self.period_start.month - 1) // 3 + 1
            return f"Q{q} {self.period_start.year}"
        return str(self.period_start)

    def __repr__(self) -> str:
        return f"<I1 {self.ico_sector} | {self.period_type} | complaints={self.complaint_count}>"


# ── I2: ICO Volume Scores ─────────────────────────────────────────────────────

class I2VolumeScores(Base):
    __tablename__ = "i2_volume_scores"

    __table_args__ = (
        CheckConstraint(
            "trend_direction IN ('Rising','Stable','Falling')",
            name="ck_i2_trend_direction"
        ),
        CheckConstraint("volume_factor >= 0", name="ck_i2_volume_factor"),
        CheckConstraint("data_lag >= 0",      name="ck_i2_data_lag"),
    )

    score_id                = Column(String(36), primary_key=True, default=lambda: str(uuid.uuid4()))
    ico_sector              = Column(String(200), nullable=False, index=True)
    ref_period_start        = Column(Date, nullable=False)
    ref_period_end          = Column(Date, nullable=False)
    complaint_count_used    = Column(Integer, nullable=False)
    avg_3period_used        = Column(Float, nullable=False)
    volume_factor           = Column(Float)
    trend_direction         = Column(String(10))
    spike_active            = Column(Boolean)
    sector_risk_modifier    = Column(Float)
    data_lag                = Column(Integer)
    stale_flag              = Column(Boolean)
    computed_at             = Column(TIMESTAMP(timezone=True), default=lambda: datetime.now(timezone.utc))

    @property
    def computed_volume_factor(self) -> Optional[float]:
        if self.complaint_count_used and self.avg_3period_used and self.avg_3period_used > 0:
            return round(self.complaint_count_used / self.avg_3period_used, 4)
        return None

    @property
    def computed_data_lag(self) -> Optional[int]:
        if self.ref_period_end:
            today = date.today()
            return (today.year - self.ref_period_end.year) * 12 + \
                   (today.month - self.ref_period_end.month)
        return None

    @property
    def computed_stale_flag(self) -> Optional[bool]:
        lag = self.computed_data_lag
        return lag > 9 if lag is not None else None

    @property
    def computed_sector_risk_modifier(self) -> Optional[float]:
        """volume_factor * trend_multiplier * spike_modifier"""
        vf = self.computed_volume_factor
        if vf is None:
            return None
        trend_mult  = {"Rising": 1.2, "Stable": 1.0, "Falling": 0.8}.get(self.trend_direction, 1.0)
        spike_mult  = 1.5 if self.spike_active else 1.0
        return round(vf * trend_mult * spike_mult, 4)

    def __repr__(self) -> str:
        return f"<I2 {self.ico_sector} | risk={self.sector_risk_modifier} | stale={self.stale_flag}>"


# ── Create tables ─────────────────────────────────────────────────────────────

def create_tables():
    Base.metadata.create_all(engine, checkfirst=True)
    print("✓ Tables ready: i1_volume_statistics, i2_volume_scores")


if __name__ == "__main__":
    create_tables()
