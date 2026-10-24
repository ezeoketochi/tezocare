export const dashboardKeys = {
  all: ["dashboard"] as const,
  summary: () => [...dashboardKeys.all, "summary"] as const,
  dueRefills: (days: number | undefined) => [...dashboardKeys.all, "due-refills", days] as const,
  dueFollowUps: (days: number | undefined) => [...dashboardKeys.all, "due-followups", days] as const,
};
