export type Gender = "male" | "female" | "other";

export interface Patient {
  id: string;
  first_name: string;
  last_name: string;
  date_of_birth: string;
  gender: Gender;
  phone: string | null;
  address: string | null;
  state: string | null;
  city: string | null;
  occupation: string | null;
  blood_group: string | null;
  genotype: string | null;
  allergies: string[];
  chronic_conditions: string[];
  emergency_contact_name: string | null;
  emergency_contact_phone: string | null;
  registered_by: string;
  created_at: string;
  updated_at: string | null;
}

export interface PatientListParams {
  skip?: number;
  limit?: number;
  search?: string;
}

export function patientFullName(p: Pick<Patient, "first_name" | "last_name">): string {
  return `${p.first_name} ${p.last_name}`.trim();
}

export function patientInitials(p: Pick<Patient, "first_name" | "last_name">): string {
  return `${p.first_name?.[0] ?? ""}${p.last_name?.[0] ?? ""}`.toUpperCase() || "?";
}

export function ageFromDob(dob: string): number | null {
  const birth = new Date(dob);
  if (Number.isNaN(birth.getTime())) return null;
  const now = new Date();
  let age = now.getFullYear() - birth.getFullYear();
  const m = now.getMonth() - birth.getMonth();
  if (m < 0 || (m === 0 && now.getDate() < birth.getDate())) age -= 1;
  return age;
}
