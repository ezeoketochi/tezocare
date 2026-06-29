from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, ConfigDict


class StaffNotificationResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    type: str
    title: str
    message: str
    status: str
    patient_id: UUID | None = None
    patient_name: str | None = None
    created_at: datetime
    read_at: datetime | None = None
