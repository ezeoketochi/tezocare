import { api } from "@/lib/api/client";
import type { NotificationsResult } from "./types";

export async function listNotifications(): Promise<NotificationsResult> {
  const { data } = await api.get<NotificationsResult>("/notifications");
  return data;
}

export async function markNotificationRead(id: string): Promise<void> {
  await api.patch<null>(`/notifications/${id}/read`);
}
