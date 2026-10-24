import { api } from "@/lib/api/client";
import type { Patient, PatientListParams } from "./types";

export async function listPatients(params: PatientListParams): Promise<{ items: Patient[]; meta: { page: number; per_page: number; total: number; total_pages: number } | null }> {
  const { data, meta } = await api.get<Patient[]>("/patients/", {
    skip: params.skip,
    limit: params.limit,
    search: params.search,
  });
  return { items: data ?? [], meta: meta ?? null };
}

export async function getPatient(id: string): Promise<Patient> {
  const { data } = await api.get<Patient>(`/patients/${id}`);
  return data;
}

export async function createPatient(payload: Record<string, unknown>): Promise<Patient> {
  const { data } = await api.post<Patient>("/patients/", payload);
  return data;
}

export async function updatePatient(id: string, payload: Record<string, unknown>): Promise<Patient> {
  const { data } = await api.patch<Patient>(`/patients/${id}`, payload);
  return data;
}
