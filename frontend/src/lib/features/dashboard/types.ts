export interface DashboardRefillItem {
  visit_id: string;
  patient_id: string;
  drug_name: string;
  dose: string;
  refill_date: string;
}

export interface RecentVisitItem {
  visit_id: string;
  patient_id: string;
  visit_date: string | null;
  status: string | null;
}

export interface DashboardSummary {
  total_patients: number;
  visits_today: number;
  follow_ups_pending: number;
  refills_due_soon: DashboardRefillItem[];
  recent_patients: RecentVisitItem[];
  upcoming_refills: DashboardRefillItem[];
}
