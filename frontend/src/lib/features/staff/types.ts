import type { Staff, StaffRole } from "@/lib/api/types";

export type { Staff, StaffRole };

export interface StaffCreatePayload {
  name: string;
  email: string;
  password: string;
  role: StaffRole;
}

export interface StaffUpdatePayload {
  name?: string;
  email?: string;
  password?: string;
  role?: StaffRole;
  is_active?: boolean;
}
