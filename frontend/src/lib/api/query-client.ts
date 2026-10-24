"use client";

import { QueryClient } from "@tanstack/react-query";
import { ApiError } from "./errors";

export function createQueryClient() {
  return new QueryClient({
    defaultOptions: {
      queries: {
        staleTime: 30_000,
        retry: (failureCount, error) => {
          if (error instanceof ApiError) {
            if (error.status === 0) return failureCount < 2; // network errors
            if (error.status >= 500) return failureCount < 2;
            return false; // never retry 4xx
          }
          return failureCount < 1;
        },
        refetchOnWindowFocus: false,
      },
      mutations: {
        retry: false,
      },
    },
  });
}
