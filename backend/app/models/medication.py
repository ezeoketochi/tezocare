import uuid
from datetime import datetime, timezone, date
from sqlalchemy import Column, String, Boolean, Text, Date, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from app.core.database import Base


class Medication(Base):
    __tablename__ = "medications"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    patient_id = Column(UUID(as_uuid=True), ForeignKey("patients.id"), index=True, nullable=False)
    visit_id = Column(UUID(as_uuid=True), ForeignKey("visits.id"), index=True, nullable=False)
    drug_name = Column(String, nullable=False)
    dosage = Column(String, nullable=False)
    frequency = Column(String, nullable=False)
    start_date = Column(Date, nullable=False)
    end_date = Column(Date, nullable=True)
    prescribed_by = Column(String, nullable=True)
    dispensed_by = Column(String, nullable=True)
    is_active = Column(Boolean, default=True, index=True)
    next_refill_date = Column(Date, index=True, nullable=True)
    notes = Column(Text, nullable=True)
    created_at = Column(DateTime(timezone=True), default=lambda: datetime.now(timezone.utc))

    patient = relationship("Patient", back_populates="medications")
    visit = relationship("Visit", back_populates="medications")
