"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getErrorMessage } from "@/lib/api/errors";
import { dashboardKeys } from "@/lib/features/dashboard/keys";
import { followUpKeys } from "@/lib/features/follow-ups/keys";
import { refillKeys } from "@/lib/features/refills/keys";
import { completeVisit, deleteVisit, getVisit, markFollowUpDone, referVisit } from "./api";
import { visitKeys } from "./keys";
import { invalidateVisitCaches } from "./hooks";

export function useVisit(id: string | undefined) {
  return useQuery({
    queryKey: visitKeys.detail(id ?? ""),
    queryFn: () => getVisit(id!),
    enabled: Boolean(id),
    staleTime: 15_000,
  });
}

function useVisitAction<TVars, TRes>(name: string, fn: (vars: TVars) => Promise<TRes>) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: fn,
    onSuccess: (visit) => {
      if (visit && typeof visit === "object" && "id" in visit) {
        const v = visit as unknown as { id: string; patient_id: string };
        invalidateVisitCaches(queryClient, v);
      } else {
        queryClient.invalidateQueries({ queryKey: refillKeys.all });
        queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
        queryClient.invalidateQueries({ queryKey: followUpKeys.all });
      }
      toast.success(name);
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}

export const useCompleteVisit = () => useVisitAction("Visit completed", (id: string) => completeVisit(id));
export const useReferVisit = () =>
  useVisitAction("Patient referred", ({ id, destination, reason }: { id: string; destination: string; reason: string }) =>
    referVisit(id, { destination, reason })
  );
export const useFollowUpDone = () =>
  useVisitAction("Follow-up recorded", ({ id, outcome }: { id: string; outcome: string }) => markFollowUpDone(id, outcome));
export const useDeleteVisit = () =>
  useVisitAction("Visit deleted", async ({ id, patientId }: { id: string; patientId: string }) => {
    await deleteVisit(id);
    return { id, patient_id: patientId } as never;
  });
