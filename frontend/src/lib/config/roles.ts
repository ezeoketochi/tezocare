import type { StaffRole } from "@/lib/api/types";

export const ROLE_LEVEL: Record<StaffRole, number> = {
  data_entry: 1,
  pharmacist: 2,
  admin: 3,
  super_admin: 4,
};

export type RoleAction =
  | "patientCreate"
  | "patientEdit"
  | "visitCreate"
  | "visitComplete"
  | "refillAction"
  | "followupAction"
  | "dashboardView"
  | "staffCrud"
  | "pharmacyEdit";

const ACTION_MIN_ROLE: Record<RoleAction, StaffRole> = {
  patientCreate: "data_entry",
  patientEdit: "data_entry",
  visitCreate: "data_entry",
  visitComplete: "pharmacist",
  refillAction: "pharmacist",
  followupAction: "pharmacist",
  dashboardView: "pharmacist",
  staffCrud: "admin",
  pharmacyEdit: "admin",
};

export function hasRole(role: StaffRole | undefined, min: StaffRole): boolean {
  if (!role) return false;
  return ROLE_LEVEL[role] >= ROLE_LEVEL[min];
}

export function can(role: StaffRole | undefined, action: RoleAction): boolean {
  return hasRole(role, ACTION_MIN_ROLE[action]);
}

export function roleLabel(role: StaffRole): string {
  switch (role) {
    case "super_admin":
      return "Super Admin";
    case "admin":
      return "Admin";
    case "pharmacist":
      return "Pharmacist";
    case "data_entry":
      return "Data Entry";
  }
}
