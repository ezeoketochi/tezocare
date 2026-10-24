import { api } from "@/lib/api/client";
import type { Staff } from "@/lib/api/types";
import type { StaffCreatePayload, StaffUpdatePayload } from "./types";

export async function listStaff(params: { skip?: number; limit?: number }): Promise<{
  items: Staff[];
  meta: { page: number; per_page: number; total: number; total_pages: number } | null;
}> {
  const { data, meta } = await api.get<Staff[]>("/staff/", { skip: params.skip, limit: params.limit });
  return { items: data ?? [], meta: meta ?? null };
}

export async function getStaff(id: string): Promise<Staff> {
  const { data } = await api.get<Staff>(`/staff/${id}`);
  return data;
}

export async function createStaff(payload: StaffCreatePayload): Promise<Staff> {
  const { data } = await api.post<Staff>("/auth/register", payload);
  return data;
}

export async function updateStaff(id: string, payload: StaffUpdatePayload): Promise<Staff> {
  const { data } = await api.patch<Staff>(`/staff/${id}`, payload);
  return data;
}

export async function deactivateStaff(id: string): Promise<void> {
  await api.del<null>(`/staff/${id}`);
}
