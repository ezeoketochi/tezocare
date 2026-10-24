export const staffKeys = {
  all: ["staff"] as const,
  list: (params: { skip?: number; limit?: number }) => [...staffKeys.all, "list", params] as const,
  detail: (id: string) => [...staffKeys.all, "detail", id] as const,
};
