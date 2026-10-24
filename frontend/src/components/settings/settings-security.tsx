"use client";

import { useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { KeyRound, LogOut } from "lucide-react";
import { toast } from "sonner";
import { Alert, AlertDescription } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { SettingsSection } from "@/components/common/settings-section";
import { FieldError, Form, FormControl, FormDescription, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { Input } from "@/components/ui/input";
import { getErrorMessage } from "@/lib/api/errors";
import { changePassword } from "@/lib/features/auth/api";
import { changePasswordSchema, type ChangePasswordValues } from "@/lib/schemas/auth";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";
import { useAuthActions } from "@/lib/features/auth/hooks";

export function SettingsSecurity() {
  const [formError, setFormError] = useState<string | null>(null);
  const { logout } = useAuthActions();

  const form = useForm<ChangePasswordValues>({
    resolver: zodResolver(changePasswordSchema),
    defaultValues: { current_password: "", new_password: "", confirm_password: "" },
  });

  async function onSubmit(values: ChangePasswordValues) {
    setFormError(null);
    try {
      await changePassword({ current_password: values.current_password, new_password: values.new_password });
      form.reset();
      toast.success("Password changed.");
    } catch (error) {
      if (!applyFieldErrors(form.setError, error)) {
        setFormError(getErrorMessage(error));
      }
    }
  }

  return (
    <Card>
      <CardContent>
        <SettingsSection icon={KeyRound} title="Password">
          {formError && (
            <Alert variant="destructive" className="mb-4">
              <AlertDescription>{formError}</AlertDescription>
            </Alert>
          )}
          <Form {...form}>
            <form onSubmit={form.handleSubmit(onSubmit)} className="grid gap-4">
              <FormField
                control={form.control}
                name="current_password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Current password</FormLabel>
                    <FormControl>
                      <Input type="password" autoComplete="current-password" {...field} />
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
                    <FormLabel>Confirm new password</FormLabel>
                    <FormControl>
                      <Input type="password" autoComplete="new-password" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <div className="flex justify-end">
                <Button type="submit" disabled={form.formState.isSubmitting}>
                  {form.formState.isSubmitting ? "Changing…" : "Change password"}
                </Button>
              </div>
            </form>
          </Form>
        </SettingsSection>

        <SettingsSection icon={LogOut} title="Session" divider={false}>
          <div className="flex flex-wrap items-center justify-between gap-3">
            <p className="min-w-0 flex-1 text-[13px] leading-[20px] font-light text-muted-foreground">
              Ends your session on this device and returns you to the sign-in screen.
            </p>
            <Button variant="ghost" onClick={() => logout()}>
              Log out
            </Button>
          </div>
        </SettingsSection>
      </CardContent>
    </Card>
  );
}
