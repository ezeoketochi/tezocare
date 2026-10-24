import { z } from "zod";

const optionalTrimmed = z.string().trim().optional().or(z.literal(""));

export const patientSchema = z.object({
  first_name: z.string().trim().min(1, "First name is required").max(100),
  last_name: z.string().trim().min(1, "Last name is required").max(100),
  date_of_birth: z.string().min(1, "Date of birth is required"),
  gender: z.enum(["male", "female", "other"], { message: "Gender is required" }),
  phone: optionalTrimmed.refine(
    (v) => !v || (v.length >= 7 && v.length <= 20),
    "Phone must be 7–20 characters"
  ),
  address: optionalTrimmed,
  state: optionalTrimmed,
  city: optionalTrimmed,
  occupation: optionalTrimmed,
  blood_group: optionalTrimmed,
  genotype: optionalTrimmed,
  allergies: z.array(z.string()),
  chronic_conditions: z.array(z.string()),
  emergency_contact_name: optionalTrimmed,
  emergency_contact_phone: optionalTrimmed,
});

export type PatientFormValues = z.infer<typeof patientSchema>;

export const patientDefaultValues: PatientFormValues = {
  first_name: "",
  last_name: "",
  date_of_birth: "",
  gender: "female",
  phone: "",
  address: "",
  state: "",
  city: "",
  occupation: "",
  blood_group: "",
  genotype: "",
  allergies: [],
  chronic_conditions: [],
  emergency_contact_name: "",
  emergency_contact_phone: "",
};
