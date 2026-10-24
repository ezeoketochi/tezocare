import { z } from "zod";

const passwordPolicy = z
  .string()
  .min(8, "Password must be at least 8 characters")
  .max(72, "Password cannot exceed 72 characters")
  .regex(/[A-Z]/, "Password must contain at least one uppercase letter")
  .regex(/\d/, "Password must contain at least one number");

export const STAFF_ROLES = ["super_admin", "admin", "pharmacist", "data_entry"] as const;

export const staffCreateSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters").max(100),
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
  password: passwordPolicy,
  role: z.enum(["admin", "pharmacist", "data_entry"]),
});
export type StaffCreateValues = z.infer<typeof staffCreateSchema>;

export const staffEditSchema = z
  .object({
    name: z.string().min(2, "Name must be at least 2 characters").max(100),
    email: z.string().min(1, "Email is required").email("Enter a valid email"),
    role: z.enum(STAFF_ROLES),
    is_active: z.boolean(),
    password: z.string(),
  })
  .refine((v) => v.password === "" || passwordPolicy.safeParse(v.password).success, {
    message: "Password must be at least 8 characters with an uppercase letter and a number",
    path: ["password"],
  });
export type StaffEditValues = z.infer<typeof staffEditSchema>;
