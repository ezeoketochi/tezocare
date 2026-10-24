"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { dashboardKeys } from "@/lib/features/dashboard/keys";
import { followUpKeys } from "@/lib/features/follow-ups/keys";
import { patientKeys } from "@/lib/features/patients/keys";
import { refillKeys } from "@/lib/features/refills/keys";
import { createVisit, updateVisit } from "./api";
import { visitKeys } from "./keys";

export function usePatientVisits(patientId: string | undefined) {
  return useQuery({
    queryKey: visitKeys.patientVisits(patientId ?? ""),
    queryFn: () => import("./api").then((m) => m.listPatientVisits(patientId!)),
    enabled: Boolean(patientId),
  });
}

export function usePatientMedications(patientId: string | undefined) {
  return useQuery({
    queryKey: visitKeys.patientMedications(patientId ?? ""),
    queryFn: () => import("./api").then((m) => m.listPatientMedications(patientId!)),
    enabled: Boolean(patientId),
  });
}

export function usePatientVitalsHistory(patientId: string | undefined) {
  return useQuery({
    queryKey: visitKeys.patientVitalsHistory(patientId ?? ""),
    queryFn: () => import("./api").then((m) => m.listPatientVitalsHistory(patientId!)),
    enabled: Boolean(patientId),
  });
}

export function useCreateVisit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: { patient_id: string; visit_date?: string }) => createVisit(payload),
    onSuccess: (visit) => {
      queryClient.invalidateQueries({ queryKey: visitKeys.patientVisits(visit.patient_id) });
      queryClient.invalidateQueries({ queryKey: patientKeys.detail(visit.patient_id) });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      return visit;
    },
    onError: (error) => toast.error(error instanceof Error ? error.message : "Could not create visit"),
  });
}

/** Everything a visit write can affect: the visit itself, its patient's projections, refills (server auto-sync), dashboard. */
export function invalidateVisitCaches(queryClient: ReturnType<typeof useQueryClient>, visit: { id: string; patient_id: string }) {
  queryClient.invalidateQueries({ queryKey: visitKeys.detail(visit.id) });
  queryClient.invalidateQueries({ queryKey: visitKeys.patientVisits(visit.patient_id) });
  queryClient.invalidateQueries({ queryKey: visitKeys.patientMedications(visit.patient_id) });
  queryClient.invalidateQueries({ queryKey: visitKeys.patientVitalsHistory(visit.patient_id) });
  queryClient.invalidateQueries({ queryKey: patientKeys.detail(visit.patient_id) });
  queryClient.invalidateQueries({ queryKey: refillKeys.all });
  queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
  queryClient.invalidateQueries({ queryKey: followUpKeys.all });
}

export function useUpdateVisit() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ id, payload }: { id: string; payload: Record<string, unknown> }) => updateVisit(id, payload),
    onSuccess: (visit) => {
      invalidateVisitCaches(queryClient, visit);
      toast.success("Visit saved");
    },
  });
}
