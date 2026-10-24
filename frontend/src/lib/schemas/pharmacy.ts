import { z } from "zod";

export const pharmacyEditSchema = z.object({
  name: z.string().min(2, "Pharmacy name must be at least 2 characters"),
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
  phone: z.string().optional(),
  address: z.string().optional(),
});
export type PharmacyEditValues = z.infer<typeof pharmacyEditSchema>;
