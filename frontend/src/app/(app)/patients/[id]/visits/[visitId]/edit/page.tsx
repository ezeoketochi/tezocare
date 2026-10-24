"use client";

import { useParams, useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/common/page-header";
import { VisitForm, visitFormToPayload } from "@/components/visits/visit-form";
import { VisitLoading } from "@/components/visits/visit-detail-view";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { useVisit } from "@/lib/features/visits/action-hooks";
import { useUpdateVisit } from "@/lib/features/visits/hooks";
import { usePatient } from "@/lib/features/patients/hooks";
import { useSession } from "@/lib/features/auth/hooks";
import { ApiError } from "@/lib/api/errors";
import type { VisitFormValues } from "@/lib/schemas/visit";

export default function VisitEditPage() {
  const params = useParams<{ id: string; visitId: string }>();
  const router = useRouter();
  const { staff } = useSession();
  const { data: visit, isPending, error } = useVisit(params.visitId);
  const { data: patient } = usePatient(params.id);
  const mutation = useUpdateVisit();

  if (isPending) return <VisitLoading />;
  if (error || !visit) return <p className="text-sm text-muted-foreground">Visit not found.</p>;

  const isCreator = staff?.id === visit.staff_id;
  if (!isCreator || visit.status !== "active") {
    return (
      <Alert variant="destructive">
        <AlertTitle>Not editable</AlertTitle>
        <AlertDescription>
          Only the staff who created a visit can edit it, and only while it is active.
        </AlertDescription>
      </Alert>
    );
  }

  function onSubmit(values: VisitFormValues) {
    // 422 field errors surface via the form below; we re-create the form component per visit.
    mutation.mutate(
      { id: visit!.id, payload: visitFormToPayload(values) },
      {
        onSuccess: () => router.push(`/patients/${params.id}/visits/${params.visitId}`),
        onError: (err) => {
          if (err instanceof ApiError && err.status === 400) {
            // Visit state changed elsewhere (e.g. completed in another tab).
            router.refresh();
          }
        },
      }
    );
  }

  return (
    <div className="mx-auto grid w-full max-w-4xl gap-5">
      <Button variant="ghost" size="sm" className="-ml-2 self-start" onClick={() => router.push(`/patients/${params.id}/visits/${params.visitId}`)}>
        <ChevronLeft data-icon="inline-start" /> Back to visit
      </Button>
      <PageHeader
        title={patient ? `Edit visit — ${patient.first_name} ${patient.last_name}` : "Edit visit"}
        description="Complete all sections, then save. Dispensed medications feed refill tracking."
      />
      <VisitForm initial={visit} submitting={mutation.isPending} onSubmit={onSubmit} />
    </div>
  );
}
