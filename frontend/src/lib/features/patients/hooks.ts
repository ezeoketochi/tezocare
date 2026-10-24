"use client";

import { keepPreviousData, useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { ApiError, getErrorMessage } from "@/lib/api/errors";
import { createPatient, getPatient, listPatients, updatePatient } from "./api";
import { patientKeys } from "./keys";
import type { PatientListParams } from "./types";

export function usePatients(params: PatientListParams) {
  return useQuery({
    queryKey: patientKeys.list(params),
    queryFn: () => listPatients(params),
    placeholderData: keepPreviousData,
    staleTime: 30_000,
  });
}

export function usePatient(id: string | undefined, options?: { enabled?: boolean }) {
  return useQuery({
    queryKey: patientKeys.detail(id ?? ""),
    queryFn: () => getPatient(id!),
    enabled: Boolean(id) && (options?.enabled ?? true),
  });
}

export function useCreatePatient() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Record<string, unknown>) => createPatient(payload),
    onSuccess: (patient) => {
      queryClient.invalidateQueries({ queryKey: patientKeys.all });
      toast.success("Patient created");
      return patient;
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}

export function useUpdatePatient(id: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Record<string, unknown>) => updatePatient(id, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: patientKeys.lists() });
      queryClient.invalidateQueries({ queryKey: patientKeys.detail(id) });
      toast.success("Patient updated");
    },
    onError: (error) => {
      if (error instanceof ApiError) toast.error(error.message);
    },
  });
}
