import { api } from "@/lib/api/client";
import type { DueFollowupsResult } from "./types";

export async function listDueFollowups(days?: number): Promise<DueFollowupsResult> {
  const { data } = await api.get<DueFollowupsResult>("/dashboard/due-followups", days ? { days } : undefined);
  return data;
}
