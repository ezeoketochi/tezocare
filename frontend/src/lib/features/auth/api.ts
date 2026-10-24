import { api } from "@/lib/api/client";
import type { LoginResponse, RefreshTokenResponse, Staff } from "@/lib/api/types";

export async function login(payload: { email: string; password: string }): Promise<LoginResponse> {
  const { data } = await api.post<LoginResponse>("/auth/login", payload, undefined, { skipAuth: true });
  return data;
}

export async function fetchMe(): Promise<Staff> {
  const { data } = await api.get<Staff>("/auth/me");
  return data;
}

export async function registerPharmacy(payload: {
  pharmacy_name: string;
  pharmacy_email: string;
  pharmacy_phone?: string;
  pharmacy_address?: string;
  admin_name: string;
  admin_email: string;
  admin_password: string;
}): Promise<unknown> {
  const { data } = await api.post("/auth/register-pharmacy", payload, undefined, { skipAuth: true });
  return data;
}

export async function registerStaff(payload: {
  name: string;
  email: string;
  password: string;
  role: string;
}): Promise<Staff> {
  const { data } = await api.post<Staff>("/auth/register", payload);
  return data;
}

export async function forgotPassword(email: string): Promise<void> {
  await api.post<null>("/auth/forgot-password", { email }, undefined, { skipAuth: true });
}

export async function verifyOtp(email: string, otp: string): Promise<string> {
  const { data } = await api.post<{ message?: string }>(
    "/auth/verify-otp",
    { email, otp },
    undefined,
    { skipAuth: true }
  );
  return data?.message ?? "OTP verified";
}

export async function resetPassword(payload: { email: string; otp: string; new_password: string }): Promise<void> {
  await api.post<null>("/auth/reset-password", payload, undefined, { skipAuth: true });
}

export async function changePassword(payload: { current_password: string; new_password: string }): Promise<void> {
  await api.post<null>("/auth/change-password", payload);
}

export async function logoutRequest(): Promise<void> {
  try {
    await api.post<null>("/auth/logout");
  } finally {
    /* clear local state even if the server call fails */
  }
}

export type { RefreshTokenResponse };
