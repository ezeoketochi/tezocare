from datetime import date, datetime
from uuid import UUID
from pydantic import BaseModel


class RefillCreateSchema(BaseModel):
    visit_id: UUID
    patient_id: UUID
    drug_name: str
    dose_amount: float | None = None
    dose_unit: str = ""
    route: str = ""
    frequency: str = ""
    frequency_code: str = ""
    duration_amount: int | None = None
    duration_unit: str = ""
    total_quantity: int | None = None
    instructions: str | None = None
    refill_date: str
    is_recurrent: bool = False
    recurrence_interval_days: int | None = None


class RefillResponse(BaseModel):
    id: UUID
    patient_id: UUID
    patient_name: str
    patient_phone: str | None = None
    visit_id: UUID
    visit_date: datetime | None = None
    drug_name: str
    dose_amount: float | None = None
    dose_unit: str = ""
    route: str = ""
    frequency: str = ""
    frequency_code: str = ""
    duration_amount: int | None = None
    duration_unit: str = ""
    total_quantity: int | None = None
    instructions: str | None = None
    refill_date: str
    days_until_refill: int
    contact_status: str
    refill_status: str
    escalated_status: str
    is_recurrent: bool = False
    recurrence_interval_days: int | None = None
    last_action_at: datetime | None = None
    prescribed_by: str | None = None


class RefillContactResponse(BaseModel):
    id: UUID
    contact_status: str
    last_action_at: datetime | None = None


class RefillFulfillResponse(BaseModel):
    id: UUID
    refill_status: str
    last_action_at: datetime | None = None
