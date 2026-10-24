import { z } from "zod";

const num = (label: string) =>
  z
    .string()
    .optional()
    .refine((v) => !v || (Number.isFinite(Number(v)) && Number(v) >= 0), `${label} must be a positive number`);

export const chiefComplaintSchema = z.object({
  complaint: z.string(),
  duration: z.string(),
});

export const testResultSchema = z.object({
  test_name: z.string(),
  result: z.string(),
});

export const medicationDispensedSchema = z.object({
  drug_name: z.string().min(1, "Drug name is required"),
  dose_amount: num("Dose amount"),
  dose_unit: z.string(),
  route: z.string(),
  frequency: z.string(),
  frequency_code: z.string(),
  duration_amount: num("Duration"),
  duration_unit: z.string(),
  total_quantity: num("Total quantity"),
  instructions: z.string(),
  date_dispensed: z.string(),
  expected_finish_date: z.string(),
  refill_date: z.string(),
  is_recurrent: z.boolean(),
  recurrence_interval_days: num("Recurrence interval"),
});

export const visitFormSchema = z
  .object({
    visit_date: z.string().min(1, "Visit date is required"),
    chief_complaints: z.array(chiefComplaintSchema),
    medication_history: z.object({
      past_medications: z.array(z.string()),
      current_medications: z.array(z.string()),
      adherence: z.string(),
      non_adherence_reason: z.string(),
    }),
    vitals: z.object({
      bp_systolic: num("Systolic BP"),
      bp_diastolic: num("Diastolic BP"),
      heart_rate: num("Heart rate"),
      temperature: num("Temperature"),
      respiratory_rate: num("Respiratory rate"),
      sp_o2: num("SpO₂"),
      weight: num("Weight"),
      height: num("Height"),
      bmi: num("BMI"),
      blood_glucose: num("Blood glucose"),
      blood_glucose_type: z.string(),
    }),
    test_results: z.array(testResultSchema),
    clinical_assessment: z.object({
      suspected_diagnosis: z.string(),
      severity: z.string(),
      pharmacist_notes: z.string(),
    }),
    medications_dispensed: z.array(medicationDispensedSchema),
    counselling_advice: z.string(),
    follow_up: z
      .object({
        required: z.boolean(),
        scheduled_date: z.string(),
        is_recurrent: z.boolean(),
        recurrence_interval_days: num("Recurrence interval"),
      })
      .refine((v) => !v.required || Boolean(v.scheduled_date), {
        message: "Scheduled date is required when a follow-up is needed",
        path: ["scheduled_date"],
      }),
    referral: z.object({
      is_referred: z.boolean(),
      destination: z.string(),
      reason: z.string(),
    }),
  })
  .refine((v) => v.medications_dispensed.every((m) => !m.is_recurrent || Boolean(m.recurrence_interval_days)), {
    message: "Recurrent medications need a recurrence interval",
    path: ["medications_dispensed"],
  });

export type VisitFormValues = z.infer<typeof visitFormSchema>;
