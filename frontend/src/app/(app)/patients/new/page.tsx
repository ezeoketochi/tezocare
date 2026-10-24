"use client";

import { useRouter } from "next/navigation";
import { PageHeader } from "@/components/common/page-header";
import { PatientForm } from "@/components/patients/patient-form";
import { RoleGate } from "@/components/guards/role-gate";
import { useCreatePatient } from "@/lib/features/patients/hooks";
import type { PatientFormValues } from "@/lib/schemas/patient";

function CreatePatientContent() {
  const router = useRouter();
  const mutation = useCreatePatient();

  function onSubmit(values: PatientFormValues) {
    const payload = Object.fromEntries(
      Object.entries(values).filter(([, v]) => v !== "" && v !== undefined)
    ) as Record<string, unknown>;
    mutation.mutate(payload, {
      onSuccess: (patient) => router.push(`/patients/${patient.id}`),
    });
  }

  return (
    <div className="mx-auto grid w-full max-w-3xl gap-5">
      <PageHeader title="New patient" description="Register a patient at your pharmacy." />
      <PatientForm submitting={mutation.isPending} onSubmit={onSubmit} onCancel={() => router.back()} />
    </div>
  );
}

export default function CreatePatientPage() {
  return (
    <RoleGate action="patientCreate">
      <CreatePatientContent />
    </RoleGate>
  );
}
