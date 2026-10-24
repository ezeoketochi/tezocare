"use client";

import { useQuery } from "@tanstack/react-query";
import { getDashboardSummary } from "./api";
import { dashboardKeys } from "./keys";

export function useDashboardSummary(enabled = true) {
  return useQuery({
    queryKey: dashboardKeys.summary(),
    queryFn: getDashboardSummary,
    staleTime: 30_000,
    enabled,
  });
}
