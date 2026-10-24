"use client";

import { useQuery } from "@tanstack/react-query";
import { listDueFollowups } from "./api";
import { followUpKeys } from "./keys";

export function useDueFollowups(days?: number) {
  return useQuery({
    queryKey: followUpKeys.list(days),
    queryFn: () => listDueFollowups(days),
    staleTime: 30_000,
  });
}

export type { DueFollowup } from "./types";
