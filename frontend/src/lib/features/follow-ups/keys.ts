export const followUpKeys = {
  all: ["followups"] as const,
  list: (days?: number) => [...followUpKeys.all, "list", days] as const,
};
