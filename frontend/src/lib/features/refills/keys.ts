export const refillKeys = {
  all: ["refills"] as const,
  list: (params: { filter?: string; days?: number }) => [...refillKeys.all, params] as const,
};
