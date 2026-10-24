"use client";

import { useParams, useRouter } from "next/navigation";
import { toast } from "sonner";
import { Skeleton } from "@/components/ui/skeleton";
import { PageHeader } from "@/components/common/page-header";
import { PatientForm } from "@/components/patients/patient-form";
import { RoleGate } from "@/components/guards/role-gate";
import { usePatient, useUpdatePatient } from "@/lib/features/patients/hooks";
import type { PatientFormValues } from "@/lib/schemas/patient";
import { ApiError } from "@/lib/api/errors";

function EditPatientContent() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { data: patient, isPending, error } = usePatient(params.id);
  const mutation = useUpdatePatient(params.id);

  if (isPending) return <Skeleton className="h-96 w-full" />;
  if (error || !patient) return <p className="text-sm text-muted-foreground">Patient not found.</p>;

  function onSubmit(values: PatientFormValues) {
    const payload = Object.fromEntries(
      Object.entries(values).map(([k, v]) => [k, v === "" ? null : v])
    ) as Record<string, unknown>;
    mutation.mutate(payload, {
      onSuccess: () => router.push(`/patients/${params.id}`),
      onError: (err) => {
        if (!(err instanceof ApiError) || Object.keys(err.fieldErrors).length === 0) {
          toast.error(err instanceof ApiError ? err.message : "Could not update patient");
        } else {
          toast.error("Please fix the highlighted fields.");
        }
      },
    });
  }

  return (
    <div className="mx-auto grid w-full max-w-3xl gap-5">
      <PageHeader title={`Edit ${patient.first_name} ${patient.last_name}`} />
      <PatientForm
        initial={patient}
        submitting={mutation.isPending}
        onSubmit={onSubmit}
        submitLabel="Save changes"
        onCancel={() => router.back()}
      />
    </div>
  );
}

export default function EditPatientPage() {
  return (
    <RoleGate action="patientEdit">
      <EditPatientContent />
    </RoleGate>
  );
}
