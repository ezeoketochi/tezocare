"use client";

import { useParams, useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { AlertCircle } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { FieldError, Form, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Skeleton } from "@/components/ui/skeleton";
import { Switch } from "@/components/ui/switch";
import { RoleGuard } from "@/components/guards/role-guard";
import { useSession } from "@/lib/features/auth/hooks";
import { useStaff, useUpdateStaff } from "@/lib/features/staff/hooks";
import type { Staff } from "@/lib/api/types";
import { STAFF_ROLES, staffEditSchema, type StaffEditValues } from "@/lib/schemas/staff";
import { applyFieldErrors } from "@/lib/utils/apply-field-errors";
import { roleLabel } from "@/lib/config/roles";

function StaffEditForm({ staff, isSelf }: { staff: Staff; isSelf: boolean }) {
  const router = useRouter();
  const updateStaff = useUpdateStaff(staff.id);
  const form = useForm<StaffEditValues>({
    resolver: zodResolver(staffEditSchema),
    defaultValues: {
      name: staff.name,
      email: staff.email,
      role: staff.role,
      is_active: staff.is_active,
      password: "",
    },
  });

  return (
    <div className="mx-auto grid w-full max-w-xl gap-5">
      <PageHeader title={`Edit ${staff.name}`} description="Update this staff member's account." />
      <Card>
        <CardContent>
          <Form {...form}>
            <form
              onSubmit={form.handleSubmit((values) =>
                updateStaff.mutate(
                  {
                    name: values.name,
                    email: values.email,
                    role: values.role,
                    is_active: values.is_active,
                    ...(values.password ? { password: values.password } : {}),
                  },
                  {
                    onSuccess: () => router.push("/settings/staff"),
                    onError: (e) => applyFieldErrors(form.setError, e),
                  }
                )
              )}
              className="space-y-4"
            >
              <FormField
                control={form.control}
                name="name"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Full name</FormLabel>
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
                name="role"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Role</FormLabel>
                    <Select value={field.value} onValueChange={(v) => field.onChange(v ?? field.value)} disabled={isSelf}>
                      <FormControl>
                        <SelectTrigger className="w-full">
                          <SelectValue />
                        </SelectTrigger>
                      </FormControl>
                      <SelectContent>
                        {STAFF_ROLES.map((r) => (
                          <SelectItem key={r} value={r}>
                            {roleLabel(r)}
                          </SelectItem>
                        ))}
                      </SelectContent>
                    </Select>
                    <FieldError />
                    {isSelf && <p className="text-xs text-muted-foreground">You can&apos;t change your own role.</p>}
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="is_active"
                render={({ field }) => (
                  <FormItem>
                    <div className="flex items-center justify-between gap-4">
                      <FormLabel>Active</FormLabel>
                      <FormControl>
                        <Switch checked={field.value} onCheckedChange={field.onChange} disabled={isSelf} />
                      </FormControl>
                    </div>
                    {isSelf && <p className="text-xs text-muted-foreground">You can&apos;t deactivate yourself.</p>}
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="password"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>New password (optional)</FormLabel>
                    <FormControl>
                      <Input type="password" placeholder="Leave blank to keep current password" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <div className="flex justify-end gap-2">
                <Button type="button" variant="outline" onClick={() => router.push("/settings/staff")}>
                  Cancel
                </Button>
                <Button type="submit" disabled={updateStaff.isPending}>
                  {updateStaff.isPending ? "Saving…" : "Save changes"}
                </Button>
              </div>
            </form>
          </Form>
        </CardContent>
      </Card>
    </div>
  );
}

function EditStaffContent({ id, selfId }: { id: string; selfId: string | undefined }) {
  const { data, isPending, error, refetch } = useStaff(id);

  if (isPending) {
    return (
      <div className="mx-auto max-w-xl space-y-3">
        <Skeleton className="h-8 w-48" />
        {Array.from({ length: 4 }).map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </div>
    );
  }

  if (error || !data) {
    return (
      <div className="mx-auto grid w-full max-w-xl gap-5">
        <Alert variant="destructive">
          <AlertCircle />
          <AlertTitle>Could not load staff member</AlertTitle>
          <AlertDescription className="flex items-center justify-between gap-2">
            <span>{error?.message ?? "Not found"}</span>
            <Button size="sm" variant="outline" onClick={() => refetch()}>
              Retry
            </Button>
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  return <StaffEditForm staff={data} isSelf={data.id === selfId} />;
}

export default function EditStaffPage() {
  const params = useParams<{ id: string }>();
  const { staff: me } = useSession();
  return (
    <RoleGuard minRole="admin">
      <EditStaffContent id={params.id} selfId={me?.id} />
    </RoleGuard>
  );
}
