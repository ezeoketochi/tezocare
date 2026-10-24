export const patientKeys = {
  all: ["patients"] as const,
  lists: () => [...patientKeys.all, "list"] as const,
  list: (params: { skip?: number; limit?: number; search?: string }) =>
    [...patientKeys.lists(), params] as const,
  details: () => [...patientKeys.all, "detail"] as const,
  detail: (id: string) => [...patientKeys.details(), id] as const,
  visits: (id: string) => [...patientKeys.detail(id), "visits"] as const,
  medications: (id: string) => [...patientKeys.detail(id), "medications"] as const,
  vitalsHistory: (id: string) => [...patientKeys.detail(id), "vitals-history"] as const,
};
