import { api } from "@/lib/api/client";
import type { Refill, RefillsListResult } from "./types";

export async function listRefills(params: { filter?: string; days?: number }): Promise<RefillsListResult> {
  const { data } = await api.get<RefillsListResult>("/refills/", params);
  return data;
}

export async function markContacted(id: string): Promise<{ id: string; contact_status: string }> {
  const { data } = await api.patch<{ id: string; contact_status: string }>(`/refills/${id}/contact`);
  return data;
}

export async function markFulfilled(id: string): Promise<{ id: string; refill_status: string }> {
  const { data } = await api.patch<{ id: string; refill_status: string }>(`/refills/${id}/fulfill`);
  return data;
}

export type { Refill };
