"use client";

import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { toast } from "sonner";
import { getErrorMessage } from "@/lib/api/errors";
import { listNotifications, markNotificationRead } from "./api";
import { notificationKeys } from "./keys";
import type { NotificationsResult } from "./types";

export function useNotifications() {
  return useQuery({
    queryKey: notificationKeys.list(),
    queryFn: listNotifications,
    staleTime: 15_000,
    refetchInterval: 60_000,
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (id: string) => markNotificationRead(id),
    onMutate: async (id) => {
      await queryClient.cancelQueries({ queryKey: notificationKeys.all });
      const previous = queryClient.getQueryData<NotificationsResult>(notificationKeys.list());
      if (previous) {
        const target = previous.notifications.find((n) => n.id === id);
        if (target && target.status !== "read") {
          queryClient.setQueryData<NotificationsResult>(notificationKeys.list(), {
            ...previous,
            notifications: previous.notifications.map((n) => (n.id === id ? { ...n, status: "read" } : n)),
            unread_count: Math.max(0, previous.unread_count - 1),
          });
        }
      }
      return { previous };
    },
    onError: (error, _id, ctx) => {
      if (ctx?.previous) queryClient.setQueryData(notificationKeys.list(), ctx.previous);
      toast.error(getErrorMessage(error));
    },
    onSettled: () => {
      queryClient.invalidateQueries({ queryKey: notificationKeys.all });
    },
  });
}

export type { StaffNotification } from "./types";
