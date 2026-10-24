"use client";

import { keepPreviousData, useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getErrorMessage } from "@/lib/api/errors";
import type { Staff } from "@/lib/api/types";
import { updateSessionStaff } from "@/lib/redux/authSlice";
import { useAppDispatch, useAppStore } from "@/lib/redux/hooks";
import { createStaff, deactivateStaff, getStaff, listStaff, updateStaff } from "./api";
import { staffKeys } from "./keys";
import type { StaffCreatePayload, StaffUpdatePayload } from "./types";

export function useStaffList(params: { skip?: number; limit?: number }) {
  return useQuery({
    queryKey: staffKeys.list(params),
    queryFn: () => listStaff(params),
    placeholderData: keepPreviousData,
    staleTime: 60_000,
  });
}

export function useStaff(id: string | undefined) {
  return useQuery({
    queryKey: staffKeys.detail(id ?? ""),
    queryFn: () => getStaff(id!),
    enabled: Boolean(id),
    staleTime: 30_000,
  });
}

export function useCreateStaff() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: StaffCreatePayload) => createStaff(payload),
    onSuccess: (staff) => {
      queryClient.invalidateQueries({ queryKey: staffKeys.all });
      toast.success(`${staff.name} added`);
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}

export function useUpdateStaff(id: string) {
  const queryClient = useQueryClient();
  const dispatch = useAppDispatch();
  const store = useAppStore();
  return useMutation({
    mutationFn: (payload: StaffUpdatePayload) => updateStaff(id, payload),
    onSuccess: (staff) => {
      queryClient.invalidateQueries({ queryKey: staffKeys.all });
      queryClient.invalidateQueries({ queryKey: staffKeys.detail(staff.id) });
      if (staff.id === store.getState().auth.staff?.id) {
        dispatch(updateSessionStaff(staff));
      }
      toast.success("Staff updated");
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}

export function useDeactivateStaff() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => deactivateStaff(id),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: staffKeys.all });
      toast.success("Staff deactivated");
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}

export type { Staff };
