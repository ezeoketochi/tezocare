"use client";

import { useCallback } from "react";
import { useQueryClient } from "@tanstack/react-query";
import { clearTokens, setTokens } from "@/lib/api/client";
import { useAppDispatch, useAppSelector } from "@/lib/redux/hooks";
import { clearAuth, hydrateSession, setSession } from "@/lib/redux/authSlice";
import { login as loginRequest, logoutRequest } from "./api";
import type { LoginResponse } from "@/lib/api/types";

export function useSession() {
  const status = useAppSelector((s) => s.auth.status);
  const staff = useAppSelector((s) => s.auth.staff);
  const pharmacy = useAppSelector((s) => s.auth.pharmacy);
  return { status, staff, pharmacy, isAuthenticated: status === "authenticated" };
}

export function useAuthActions() {
  const dispatch = useAppDispatch();
  const queryClient = useQueryClient();

  const login = useCallback(
    async (payload: { email: string; password: string }) => {
      const result: LoginResponse = await loginRequest(payload);
      setTokens({ access_token: result.access_token, refresh_token: result.refresh_token });
      queryClient.clear();
      dispatch(
        setSession({
          staff: {
            id: result.staff.id,
            name: result.staff.name,
            email: result.staff.email,
            role: result.staff.role,
            is_active: true,
            pharmacy_id: result.pharmacy?.id ?? null,
            created_at: "",
            updated_at: null,
            pharmacy: result.pharmacy,
          },
          pharmacy: result.pharmacy,
        })
      );
      return result;
    },
    [dispatch, queryClient]
  );

  const logout = useCallback(async () => {
    await logoutRequest();
    clearTokens();
    queryClient.clear();
    dispatch(clearAuth());
  }, [dispatch, queryClient]);

  const refreshSession = useCallback(() => dispatch(hydrateSession()), [dispatch]);

  return { login, logout, refreshSession };
}
