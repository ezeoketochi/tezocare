import { z } from "zod";

const passwordPolicy = (fieldName: string) =>
  z
    .string()
    .min(8, `${fieldName} must be at least 8 characters`)
    .max(72, `${fieldName} cannot exceed 72 characters`)
    .regex(/[A-Z]/, `${fieldName} must contain at least one uppercase letter`)
    .regex(/\d/, `${fieldName} must contain at least one number`);

export const loginSchema = z.object({
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
  password: z.string().min(6, "Password must be at least 6 characters").max(72),
});
export type LoginValues = z.infer<typeof loginSchema>;

export const registerPharmacySchema = z.object({
  pharmacy_name: z.string().min(2, "Pharmacy name must be at least 2 characters"),
  pharmacy_email: z.string().min(1, "Email is required").email("Enter a valid email"),
  pharmacy_phone: z.string().optional(),
  pharmacy_address: z.string().optional(),
  admin_name: z.string().min(2, "Name must be at least 2 characters").max(100),
  admin_email: z.string().min(1, "Email is required").email("Enter a valid email"),
  admin_password: passwordPolicy("Password"),
});
export type RegisterPharmacyValues = z.infer<typeof registerPharmacySchema>;

export const registerStaffSchema = z.object({
  name: z.string().min(2, "Name must be at least 2 characters").max(100),
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
  password: passwordPolicy("Password"),
  role: z.enum(["admin", "pharmacist", "data_entry"]),
});
export type RegisterStaffValues = z.infer<typeof registerStaffSchema>;

export const forgotPasswordSchema = z.object({
  email: z.string().min(1, "Email is required").email("Enter a valid email"),
});
export type ForgotPasswordValues = z.infer<typeof forgotPasswordSchema>;

export const otpSchema = z.object({
  otp: z.string().length(6, "OTP must be a 6-digit code").regex(/^\d+$/, "OTP must be a 6-digit code"),
});
export type OtpValues = z.infer<typeof otpSchema>;

export const resetPasswordSchema = z
  .object({
    email: z.string().min(1, "Email is required").email("Enter a valid email"),
    otp: z.string().length(6, "OTP must be a 6-digit code").regex(/^\d+$/, "OTP must be a 6-digit code"),
    new_password: passwordPolicy("Password"),
    confirm_password: z.string(),
  })
  .refine((v) => v.new_password === v.confirm_password, {
    message: "Passwords do not match",
    path: ["confirm_password"],
  });
export type ResetPasswordValues = z.infer<typeof resetPasswordSchema>;

export const changePasswordSchema = z
  .object({
    current_password: z.string().min(1, "Current password is required"),
    new_password: passwordPolicy("Password"),
    confirm_password: z.string(),
  })
  .refine((v) => v.new_password === v.confirm_password, {
    message: "Passwords do not match",
    path: ["confirm_password"],
  });
export type ChangePasswordValues = z.infer<typeof changePasswordSchema>;
