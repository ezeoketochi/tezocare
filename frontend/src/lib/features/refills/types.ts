export interface Refill {
  id: string;
  patient_id: string;
  patient_name: string;
  patient_phone: string | null;
  visit_id: string;
  visit_date: string | null;
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
  refill_date: string;
  days_until_refill: number;
  contact_status: string;
  refill_status: string;
  escalated_status: string;
  sig_string?: string;
  is_recurrent: boolean;
  recurrence_interval_days: number | null;
  last_action_at: string | null;
  prescribed_by: string | null;
}

export interface RefillsListResult {
  total: number;
  overdue: number;
  due_today: number;
  outreach: number;
  refills: Refill[];
}

export const ESCALATION_PHASES = {
  outreach: "Phase 1 (Outreach)",
  dueToday: "Phase 2 (Due Today)",
  overdue: "Phase 3 (Overdue)",
  upcoming: "upcoming",
} as const;

export function phaseBadgeVariant(status: string): "default" | "secondary" | "outline" | "destructive" {
  if (status === ESCALATION_PHASES.overdue) return "destructive";
  if (status === ESCALATION_PHASES.dueToday) return "default";
  if (status === ESCALATION_PHASES.outreach) return "outline";
  return "secondary";
}

export function normalizePhone(phone: string | null): string {
  return (phone ?? "").replace(/[^0-9+]/g, "");
}

export function whatsappUrl(phone: string | null, message: string): string {
  return `https://wa.me/${normalizePhone(phone)}?text=${encodeURIComponent(message)}`;
}

export function refillReminderMessage(refill: Refill): string {
  const sig = refill.sig_string || `${refill.drug_name} ${refill.dose_amount ?? ""}${refill.dose_unit ?? ""}`.trim();
  return `TezoCare reminder: your refill for "${sig}" is due on ${refill.refill_date}. Please visit your pharmacy to collect it.`;
}
