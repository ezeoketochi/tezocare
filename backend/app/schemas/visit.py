from datetime import date, datetime
from uuid import UUID
from pydantic import BaseModel, ConfigDict, Field
from app.models.visit import VisitStatus


class ChiefComplaintItem(BaseModel):
    complaint: str = ""
    duration: str = ""


class MedicationHistory(BaseModel):
    past_medications: list[str] = []
    current_medications: list[str] = []
    adherence: str | None = None
    non_adherence_reason: str | None = None


class VitalsData(BaseModel):
    bp_systolic: int | None = None
    bp_diastolic: int | None = None
    heart_rate: int | None = None
    temperature: float | None = None
    respiratory_rate: int | None = None
    sp_o2: int | None = None
    weight: float | None = None
    height: float | None = None
    bmi: float | None = None
    blood_glucose: float | None = None
    blood_glucose_type: str | None = None


class TestResultItem(BaseModel):
    test_name: str = ""
    result: str = ""


class ClinicalAssessment(BaseModel):
    suspected_diagnosis: str | None = None
    severity: str | None = None
    pharmacist_notes: str | None = None


class MedicationDispensed(BaseModel):
    drug_name: str = ""
    dose_amount: float | None = None
    dose_unit: str = ""
    route: str = ""
    frequency: str = ""
    frequency_code: str = ""
    duration_amount: int | None = None
    duration_unit: str = ""
    total_quantity: int | None = None
    instructions: str | None = None
    date_dispensed: str | None = None
    expected_finish_date: str | None = None
    refill_date: str | None = None
    is_recurrent: bool = False
    recurrence_interval_days: int | None = None


class FollowUp(BaseModel):
    required: bool = False
    scheduled_date: str | None = None
    is_done: bool = False
    outcome: str | None = None
    date_completed: str | None = None
    is_recurrent: bool = False
    recurrence_interval_days: int | None = None


class Referral(BaseModel):
    is_referred: bool = False
    destination: str | None = None
    reason: str | None = None


class VisitCreate(BaseModel):
    patient_id: UUID
    visit_date: datetime | None = None


class VisitUpdate(BaseModel):
    visit_date: datetime | None = None
    chief_complaints: list[ChiefComplaintItem] | None = None
    medication_history: MedicationHistory | None = None
    vitals: VitalsData | None = None
    test_results: list[TestResultItem] | None = None
    clinical_assessment: ClinicalAssessment | None = None
    medications_dispensed: list[MedicationDispensed] | None = None
    counselling_advice: str | None = None
    follow_up: FollowUp | None = None
    referral: Referral | None = None


class VisitResponse(BaseModel):
    model_config = ConfigDict(from_attributes=True)

    id: UUID
    patient_id: UUID
    staff_id: UUID
    visit_number: int
    visit_date: datetime
    status: VisitStatus
    chief_complaints: list[ChiefComplaintItem] = []
    medication_history: MedicationHistory = MedicationHistory()
    vitals: VitalsData = VitalsData()
    test_results: list[TestResultItem] = []
    clinical_assessment: ClinicalAssessment = ClinicalAssessment()
    medications_dispensed: list[MedicationDispensed] = []
    counselling_advice: str | None = None
    follow_up: FollowUp = FollowUp()
    referral: Referral = Referral()
    created_at: datetime
    updated_at: datetime | None


class ReferPatientRequest(BaseModel):
    destination: str = Field(..., min_length=1)
    reason: str = Field(..., min_length=1)


class FollowUpDoneRequest(BaseModel):
    outcome: str = Field(..., min_length=1)
