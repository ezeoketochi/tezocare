"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { toast } from "sonner";
import { MailCheck } from "lucide-react";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { FieldError, Form, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { Input } from "@/components/ui/input";
import { getErrorMessage } from "@/lib/api/errors";
import { forgotPassword } from "@/lib/features/auth/api";
import { forgotPasswordSchema, type ForgotPasswordValues } from "@/lib/schemas/auth";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";

export default function ForgotPasswordPage() {
  const router = useRouter();
  const [formError, setFormError] = useState<string | null>(null);
  const [sentEmail, setSentEmail] = useState<string | null>(null);

  const form = useForm<ForgotPasswordValues>({
    resolver: zodResolver(forgotPasswordSchema),
    defaultValues: { email: "" },
  });

  async function onSubmit(values: ForgotPasswordValues) {
    setFormError(null);
    try {
      await forgotPassword(values.email);
      setSentEmail(values.email);
      toast.success("If the account exists, a 6-digit code is on its way.");
    } catch (error) {
      if (!applyFieldErrors(form.setError, error)) {
        setFormError(getErrorMessage(error));
      }
    }
  }

  return (
    <Card>
      <CardHeader>
        <CardTitle>Forgot password</CardTitle>
        <CardDescription>Enter your email and we will send you a 6-digit verification code.</CardDescription>
      </CardHeader>
      <CardContent className="space-y-4">
        {formError && (
          <Alert variant="destructive">
            <AlertDescription>{formError}</AlertDescription>
          </Alert>
        )}
        {sentEmail ? (
          <div className="grid gap-5">
            <Alert>
              <MailCheck className="size-4" />
              <AlertDescription>
                Verification code sent for <span className="font-medium">{sentEmail}</span>. It expires in 15 minutes.
              </AlertDescription>
            </Alert>
            <Button
              className="w-full"
              onClick={() => router.push(`/verify-otp?email=${encodeURIComponent(sentEmail)}`)}
            >
              Enter code
            </Button>
          </div>
        ) : (
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
              <FormField
                control={form.control}
                name="email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input type="email" placeholder="you@pharmacy.com" autoComplete="email" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <Button type="submit" size="lg" className="w-full" disabled={form.formState.isSubmitting}>
                {form.formState.isSubmitting ? "Sending code…" : "Send code"}
              </Button>
            </form>
          </Form>
        )}
        <p className="text-center text-sm text-muted-foreground">
          Remembered it?{" "}
          <Link href="/login" className="font-medium text-primary underline-offset-4 hover:underline">
            Back to sign in
          </Link>
        </p>
      </CardContent>
    </Card>
  );
}
