"use client";

import { Suspense, useState } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { toast } from "sonner";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { FieldError, Form, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { OtpInput } from "@/components/common/otp-input";
import { getErrorMessage } from "@/lib/api/errors";
import { verifyOtp } from "@/lib/features/auth/api";
import { otpSchema, type OtpValues } from "@/lib/schemas/auth";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";

function OtpForm() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const email = searchParams.get("email") ?? "";
  const [formError, setFormError] = useState<string | null>(null);

  const form = useForm<OtpValues>({
    resolver: zodResolver(otpSchema),
    defaultValues: { otp: "" },
  });

  async function onSubmit(values: OtpValues) {
    setFormError(null);
    try {
      await verifyOtp(email, values.otp);
      toast.success("Code verified.");
      router.push(`/reset-password?email=${encodeURIComponent(email)}&otp=${encodeURIComponent(values.otp)}`);
    } catch (error) {
      if (!applyFieldErrors(form.setError, error)) {
        setFormError(getErrorMessage(error));
      }
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Verify your code</CardTitle>
        <CardDescription>
          Enter the 6-digit code sent for <span className="font-medium text-foreground">{email}</span>.
        </CardDescription>
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
              name="otp"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Verification code</FormLabel>
                  <FormControl>
                    <OtpInput
                      value={field.value ?? ""}
                      disabled={form.formState.isSubmitting}
                      onChange={(next) => {
                        field.onChange(next);
                        if (next.length === 6) void form.handleSubmit(onSubmit)();
                      }}
                    />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
            <Button type="submit" size="lg" className="w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "Verifying…" : "Verify code"}
            </Button>
          </form>
        </Form>
        <p className="text-center text-sm text-muted-foreground">
          Wrong email?{" "}
          <Link href="/forgot-password" className="font-medium text-primary underline-offset-4 hover:underline">
            Start over
          </Link>
        </p>
      </CardContent>
    </Card>
  );
}

export default function VerifyOtpPage() {
  return (
    <Suspense>
      <OtpForm />
    </Suspense>
  );
}
