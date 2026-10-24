import { api } from "@/lib/api/client";
import type { Pharmacy } from "./types";

export async function getMyPharmacy(): Promise<Pharmacy> {
  const { data } = await api.get<Pharmacy>("/pharmacies/me");
  return data;
}

export async function updateMyPharmacy(payload: Partial<Pharmacy>): Promise<Pharmacy> {
  const { data } = await api.patch<Pharmacy>("/pharmacies/me", payload);
  return data;
}
