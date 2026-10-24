"use client";

import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Building2 } from "lucide-react";
import { Button } from "@/components/ui/button";
import { SettingsSection } from "@/components/common/settings-section";
import { FieldError, Form, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { Input } from "@/components/ui/input";
import { useUpdateMyPharmacy } from "@/lib/features/pharmacy/hooks";
import type { Pharmacy } from "@/lib/features/pharmacy/types";
import { pharmacyEditSchema, type PharmacyEditValues } from "@/lib/schemas/pharmacy";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";

export function PharmacyForm({ pharmacy }: { pharmacy: Pharmacy }) {
  const form = useForm<PharmacyEditValues>({
    resolver: zodResolver(pharmacyEditSchema),
    defaultValues: {
      name: pharmacy.name,
      email: pharmacy.email,
      phone: pharmacy.phone ?? "",
      address: pharmacy.address ?? "",
    },
  });
  const updatePharmacy = useUpdateMyPharmacy();

  return (
    <Form {...form}>
      <form
        onSubmit={form.handleSubmit((values) =>
          updatePharmacy.mutate(
            {
              name: values.name,
              email: values.email,
              phone: values.phone || undefined,
              address: values.address || undefined,
            },
            { onError: (e) => applyFieldErrors(form.setError, e) }
          )
        )}
      >
        <SettingsSection icon={Building2} title="Pharmacy details" divider={false}>
          <div className="grid gap-4 sm:grid-cols-3">
            <FormField
              control={form.control}
              name="name"
              render={({ field }) => (
                <FormItem className="sm:col-span-2">
                  <FormLabel>Pharmacy name</FormLabel>
                  <FormControl>
                    <Input {...field} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
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
              name="phone"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Phone</FormLabel>
                  <FormControl>
                    <Input placeholder="+234…" {...field} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="address"
              render={({ field }) => (
                <FormItem className="sm:col-span-2">
                  <FormLabel>Address</FormLabel>
                  <FormControl>
                    <Input {...field} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
          </div>
          <div className="mt-5 flex justify-end">
            <Button type="submit" disabled={updatePharmacy.isPending}>
              {updatePharmacy.isPending ? "Saving…" : "Save changes"}
            </Button>
          </div>
        </SettingsSection>
      </form>
    </Form>
  );
}
