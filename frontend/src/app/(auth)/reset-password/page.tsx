"use client";

import { Suspense, useState } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { toast } from "sonner";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { FieldError, Form, FormControl, FormDescription, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { OtpInput } from "@/components/common/otp-input";
import { Input } from "@/components/ui/input";
import { getErrorMessage } from "@/lib/api/errors";
import { resetPassword } from "@/lib/features/auth/api";
import { resetPasswordSchema, type ResetPasswordValues } from "@/lib/schemas/auth";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";

function ResetPasswordForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const email = searchParams.get("email") ?? "";
  const otp = searchParams.get("otp") ?? "";
  const [formError, setFormError] = useState<string | null>(null);

  const form = useForm<ResetPasswordValues>({
    resolver: zodResolver(resetPasswordSchema),
    defaultValues: { email, otp, new_password: "", confirm_password: "" },
  });

  async function onSubmit(values: ResetPasswordValues) {
    setFormError(null);
    try {
      await resetPassword({ email: values.email, otp: values.otp, new_password: values.new_password });
      toast.success("Password reset. Please sign in.");
      router.replace("/login");
    } catch (error) {
      if (!applyFieldErrors(form.setError, error)) {
        setFormError(getErrorMessage(error));
      }
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Set a new password</CardTitle>
        <CardDescription>Choose a new password for {email}.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {formError && (
          <Alert variant="destructive">
            <AlertDescription>{formError}</AlertDescription>
          </Alert>
        )}
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <FormField
              control={form.control}
              name="email"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Email</FormLabel>
                  <FormControl>
                    <Input type="email" {...field} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="otp"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Verification code</FormLabel>
                  <FormControl>
                    <OtpInput value={field.value ?? ""} onChange={field.onChange} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="new_password"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>New password</FormLabel>
                  <FormControl>
                    <Input type="password" autoComplete="new-password" {...field} />
                  </FormControl>
                  <FieldError />
                  <FormDescription>At least 8 characters with an uppercase letter and a number.</FormDescription>
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="confirm_password"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Confirm password</FormLabel>
                  <FormControl>
                    <Input type="password" autoComplete="new-password" {...field} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
            <Button type="submit" size="lg" className="w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "Resetting…" : "Reset password"}
            </Button>
          </form>
        </Form>
      </CardContent>
    </Card>
  );
}

export default function ResetPasswordPage() {
  return (
    <Suspense>
      <ResetPasswordForm />
    </Suspense>
  );
}
