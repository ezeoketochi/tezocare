from datetime import date, datetime
from typing import Optional
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field
from app.models.patient import Gender


class PatientBase(BaseModel):
    first_name: str = Field(..., min_length=1, max_length=100)
    last_name: str = Field(..., min_length=1, max_length=100)
    date_of_birth: date
    gender: Gender
    phone: Optional[str] = None
    address: Optional[str] = None
    state: Optional[str] = None
    city: Optional[str] = None
    occupation: Optional[str] = None
    blood_group: Optional[str] = None
    genotype: Optional[str] = None
    allergies: list[str] = []
    chronic_conditions: list[str] = []
    emergency_contact_name: str | None = None
    emergency_contact_phone: str | None = None


class PatientCreate(PatientBase):
    registered_by: UUID | None = None


class PatientUpdate(BaseModel):
    first_name: str | None = Field(None, min_length=1, max_length=100)
    last_name: str | None = Field(None, min_length=1, max_length=100)
    date_of_birth: date | None = None
    gender: Gender | None = None
    phone: str | None = Field(None, min_length=7, max_length=20)
    address: str | None = None
    state: str | None = None
    city: str | None = None
    occupation: str | None = None
    blood_group: str | None = None
    genotype: str | None = None
    allergies: list[str] | None = None
    chronic_conditions: list[str] | None = None
    emergency_contact_name: str | None = None
    emergency_contact_phone: str | None = None


class PatientResponse(PatientBase):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    registered_by: UUID
    created_at: datetime
    updated_at: datetime | None
