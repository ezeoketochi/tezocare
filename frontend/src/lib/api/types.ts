export type StaffRole = "super_admin" | "admin" | "pharmacist" | "data_entry";

export interface Staff {
  id: string;
  name: string;
  email: string;
  role: StaffRole;
  is_active: boolean;
  pharmacy_id: string | null;
  created_at: string;
  updated_at: string | null;
  pharmacy?: SessionPharmacy | null;
}

export interface SessionPharmacy {
  id: string;
  name: string | null;
}

export interface LoginResponse {
  access_token: string;
  refresh_token: string;
  token_type: string;
  staff: Pick<Staff, "id" | "name" | "email" | "role">;
  pharmacy: SessionPharmacy | null;
}

export interface RefreshTokenResponse {
  access_token: string;
  refresh_token?: string;
  token_type?: string;
}
