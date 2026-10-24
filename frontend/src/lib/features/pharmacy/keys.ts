export const pharmacyKeys = {
  all: ["pharmacy"] as const,
  me: () => [...pharmacyKeys.all, "me"] as const,
};
