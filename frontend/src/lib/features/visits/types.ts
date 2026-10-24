export type VisitStatus = "active" | "completed" | "follow_up_pending" | "referred";

export interface ChiefComplaintItem {
  complaint: string;
  duration: string;
}

export interface MedicationHistory {
  past_medications: string[];
  current_medications: string[];
  adherence: string | null;
  non_adherence_reason: string | null;
}

export interface VitalsData {
  bp_systolic: number | null;
  bp_diastolic: number | null;
  heart_rate: number | null;
  temperature: number | null;
  respiratory_rate: number | null;
  sp_o2: number | null;
  weight: number | null;
  height: number | null;
  bmi: number | null;
  blood_glucose: number | null;
  blood_glucose_type: string | null;
}

export interface TestResultItem {
  test_name: string;
  result: string;
}

export interface ClinicalAssessment {
  suspected_diagnosis: string | null;
  severity: string | null;
  pharmacist_notes: string | null;
}

export interface MedicationDispensed {
  drug_name: string;
  dose_amount: number | null;
  dose_unit: string;
  route: string;
  frequency: string;
  frequency_code: string;
  duration_amount: number | null;
  duration_unit: string;
  total_quantity: number | null;
  instructions: string | null;
  date_dispensed: string | null;
  expected_finish_date: string | null;
  refill_date: string | null;
  is_recurrent: boolean;
  recurrence_interval_days: number | null;
}

export interface FollowUp {
  required: boolean;
  scheduled_date: string | null;
  is_done: boolean;
  outcome: string | null;
  date_completed: string | null;
  is_recurrent: boolean;
  recurrence_interval_days: number | null;
}

export interface Referral {
  is_referred: boolean;
  destination: string | null;
  reason: string | null;
}

export interface Visit {
  id: string;
  patient_id: string;
  staff_id: string;
  visit_number: number;
  visit_date: string;
  status: VisitStatus;
  chief_complaints: ChiefComplaintItem[];
  medication_history: MedicationHistory;
  vitals: VitalsData;
  test_results: TestResultItem[];
  clinical_assessment: ClinicalAssessment;
  medications_dispensed: MedicationDispensed[];
  counselling_advice: string | null;
  follow_up: FollowUp;
  referral: Referral;
  created_at: string;
  updated_at: string | null;
}

/** GET /patients/{id}/medications returns dispensed meds enriched with visit info. */
export interface PatientMedication extends MedicationDispensed {
  visit_id: string;
  visit_date: string;
  prescribed_by: string | null;
}

export interface VitalsHistoryEntry extends VitalsData {
  visit_id: string;
  visit_date: string;
}
