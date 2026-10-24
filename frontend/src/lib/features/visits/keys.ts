export const visitKeys = {
  all: ["visits"] as const,
  detail: (id: string) => ["visits", id] as const,
  patientVisits: (patientId: string) => ["patients", patientId, "visits"] as const,
  patientMedications: (patientId: string) => ["patients", patientId, "medications"] as const,
  patientVitalsHistory: (patientId: string) => ["patients", patientId, "vitals-history"] as const,
};
