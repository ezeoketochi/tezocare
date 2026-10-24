import { api } from "@/lib/api/client";
import type { PatientMedication, Visit, VitalsHistoryEntry } from "./types";

export async function listPatientVisits(patientId: string): Promise<Visit[]> {
  const { data } = await api.get<Visit[]>(`/patients/${patientId}/visits`);
  return data ?? [];
}

export async function getVisit(id: string): Promise<Visit> {
  const { data } = await api.get<Visit>(`/visits/${id}`);
  return data;
}

export async function createVisit(payload: { patient_id: string; visit_date?: string }): Promise<Visit> {
  const { data } = await api.post<Visit>("/visits/", payload);
  return data;
}

export async function updateVisit(id: string, payload: Record<string, unknown>): Promise<Visit> {
  const { data } = await api.patch<Visit>(`/visits/${id}`, payload);
  return data;
}

export async function completeVisit(id: string): Promise<Visit> {
  const { data } = await api.patch<Visit>(`/visits/${id}/complete`);
  return data;
}

export async function referVisit(id: string, payload: { destination: string; reason: string }): Promise<Visit> {
  const { data } = await api.patch<Visit>(`/visits/${id}/refer`, payload);
  return data;
}

export async function markFollowUpDone(id: string, outcome: string): Promise<Visit> {
  const { data } = await api.patch<Visit>(`/visits/${id}/followup-done`, { outcome });
  return data;
}

export async function deleteVisit(id: string): Promise<void> {
  await api.del<null>(`/visits/${id}`);
}

export async function listPatientMedications(patientId: string): Promise<PatientMedication[]> {
  const { data } = await api.get<PatientMedication[]>(`/patients/${patientId}/medications`);
  return data ?? [];
}

export async function listPatientVitalsHistory(patientId: string): Promise<VitalsHistoryEntry[]> {
  const { data } = await api.get<VitalsHistoryEntry[]>(`/patients/${patientId}/vitals-history`);
  return data ?? [];
}
