"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { dashboardKeys } from "@/lib/features/dashboard/keys";
import { getErrorMessage } from "@/lib/api/errors";
import { listRefills, markContacted, markFulfilled } from "./api";
import { refillKeys } from "./keys";
import type { Refill, RefillsListResult } from "./types";

export function useRefills() {
  return useQuery({
    queryKey: refillKeys.list({}),
    queryFn: () => listRefills({}),
    staleTime: 30_000,
  });
}

export function useContactRefill() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => markContacted(id),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: refillKeys.all });
      const previous = queryClient.getQueryData<RefillsListResult>(refillKeys.list({}));
      if (previous) {
        queryClient.setQueryData<RefillsListResult>(refillKeys.list({}), {
          ...previous,
          refills: previous.refills.map((r) => (r.id === id ? { ...r, contact_status: "contacted" } : r)),
        });
      }
      return { previous };
    },
    onError: (error, _id, ctx) => {
      if (ctx?.previous) queryClient.setQueryData(refillKeys.list({}), ctx.previous);
      toast.error(getErrorMessage(error));
    },
    onSuccess: () => toast.success("Marked as contacted"),
  });
}

export function useFulfillRefill() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => markFulfilled(id),
    onSuccess: (result, id) => {
      // Fulfilling a recurrent refill clones a successor row — refetch everything.
      queryClient.invalidateQueries({ queryKey: refillKeys.all });
      queryClient.invalidateQueries({ queryKey: dashboardKeys.all });
      toast.success(result.refill_status === "completed" ? "Refill fulfilled" : "Updated");
      void id;
    },
    onError: (error) => toast.error(getErrorMessage(error)),
  });
}

export type { Refill };
