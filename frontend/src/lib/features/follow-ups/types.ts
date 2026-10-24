export interface FollowUpMedication {
  drug_name: string;
  dose: string;
  frequency: string;
}

export interface DueFollowup {
  patient_id: string;
  patient_name: string;
  patient_phone: string | null;
  visit_id: string;
  visit_date: string | null;
  scheduled_date: string | null;
  days_until_followup: number;
  followup_status: string;
  outcome: string | null;
  suspected_diagnosis: string | null;
  medications_dispensed: FollowUpMedication[];
  attending_staff: string | null;
}

export interface DueFollowupsResult {
  total: number;
  overdue: number;
  due_today: number;
  upcoming: number;
  followups: DueFollowup[];
}

export const FOLLOWUP_STATUS_LABELS: Record<string, string> = {
  overdue: "Overdue",
  due_today: "Due today",
  upcoming: "Upcoming",
};
