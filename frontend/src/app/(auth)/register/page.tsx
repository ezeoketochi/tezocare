"use client";

import { useState } from "react";
import Link from "next/link";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { toast } from "sonner";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card";
import { FieldError, Form, FormDescription, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { Input } from "@/components/ui/input";
import { getErrorMessage } from "@/lib/api/errors";
import { registerPharmacy } from "@/lib/features/auth/api";
import { registerPharmacySchema, type RegisterPharmacyValues } from "@/lib/schemas/auth";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";

export default function RegisterPage() {
  const router = useRouter();
  const [formError, setFormError] = useState<string | null>(null);

  const form = useForm<RegisterPharmacyValues>({
    resolver: zodResolver(registerPharmacySchema),
    defaultValues: {
      pharmacy_name: "",
      pharmacy_email: "",
      pharmacy_phone: "",
      pharmacy_address: "",
      admin_name: "",
      admin_email: "",
      admin_password: "",
    },
  });

  async function onSubmit(values: RegisterPharmacyValues) {
    setFormError(null);
    try {
      await registerPharmacy({
        ...values,
        pharmacy_phone: values.pharmacy_phone || undefined,
        pharmacy_address: values.pharmacy_address || undefined,
      });
      toast.success("Pharmacy account created — please sign in.");
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
        <CardTitle>Create your pharmacy</CardTitle>
        <CardDescription>
          Register a new pharmacy workspace. You will become its administrator and can invite staff afterwards.
        </CardDescription>
      </CardHeader>
      <CardContent>
        {formError && (
          <Alert variant="destructive" className="mb-4">
            <AlertDescription>{formError}</AlertDescription>
          </Alert>
        )}
        <Form {...form}>
          <form onSubmit={form.handleSubmit(onSubmit)} className="space-y-4">
            <div className="grid gap-4">
              <h3 className="text-sm font-semibold text-muted-foreground">Pharmacy details</h3>
              <FormField
                control={form.control}
                name="pharmacy_name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Pharmacy name</FormLabel>
                    <FormControl>
                      <Input placeholder="Tezocare Pharmacy" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="pharmacy_email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Pharmacy email</FormLabel>
                    <FormControl>
                      <Input type="email" placeholder="hello@pharmacy.com" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <div className="grid gap-4 sm:grid-cols-2">
                <FormField
                  control={form.control}
                  name="pharmacy_phone"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Phone (optional)</FormLabel>
                      <FormControl>
                        <Input placeholder="+234..." {...field} />
                      </FormControl>
                      <FieldError />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="pharmacy_address"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Address (optional)</FormLabel>
                      <FormControl>
                        <Input placeholder="12 Main Street, Lagos" {...field} />
                      </FormControl>
                      <FieldError />
                    </FormItem>
                  )}
                />
              </div>
            </div>
            <div className="grid gap-4">
              <h3 className="text-sm font-semibold text-muted-foreground">Administrator account</h3>
              <FormField
                control={form.control}
                name="admin_name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Your name</FormLabel>
                    <FormControl>
                      <Input placeholder="Jane Doe" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="admin_email"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Email</FormLabel>
                    <FormControl>
                      <Input type="email" placeholder="you@pharmacy.com" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="admin_password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Password</FormLabel>
                    <FormControl>
                      <Input type="password" autoComplete="new-password" {...field} />
                    </FormControl>
                    <FieldError />
                    <FormDescription>At least 8 characters with an uppercase letter and a number.</FormDescription>
                  </FormItem>
                )}
              />
            </div>
            <Button type="submit" size="lg" className="w-full" disabled={form.formState.isSubmitting}>
              {form.formState.isSubmitting ? "Creating account…" : "Create pharmacy account"}
            </Button>
          </form>
        </Form>
        <p className="mt-4 text-center text-sm text-muted-foreground">
          Already have an account?{" "}
          <Link href="/login" className="font-medium text-primary underline-offset-4 hover:underline">
            Sign in
          </Link>
        </p>
      </CardContent>
    </Card>
  );
}
