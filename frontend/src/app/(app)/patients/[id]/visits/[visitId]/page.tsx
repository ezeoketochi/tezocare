"use client";

import { useParams, useRouter } from "next/navigation";
import { ChevronLeft } from "lucide-react";
import { Button } from "@/components/ui/button";
import { PageHeader } from "@/components/common/page-header";
import { VisitContentView, VisitLoading } from "@/components/visits/visit-detail-view";
import { useVisit } from "@/lib/features/visits/action-hooks";
import { usePatient } from "@/lib/features/patients/hooks";
import { patientFullName } from "@/lib/features/patients/types";

export default function VisitDetailPage() {
  const params = useParams<{ id: string; visitId: string }>();
  const router = useRouter();
  const { data: visit, isPending, error } = useVisit(params.visitId);
  const { data: patient } = usePatient(params.id);

  if (isPending) return <VisitLoading />;
  if (error || !visit) return <p className="text-sm text-muted-foreground">Visit not found.</p>;

  return (
    <div className="grid gap-5">
      <Button variant="ghost" size="sm" className="-ml-2 self-start" onClick={() => router.push(`/patients/${params.id}`)}>
        <ChevronLeft data-icon="inline-start" /> {patient ? patientFullName(patient) : "Patient"}
      </Button>
      <PageHeader
        title={patient ? `Visit — ${patientFullName(patient)}` : `Visit #${visit.visit_number}`}
        description={`Attending staff record for visit #${visit.visit_number}.`}
      />
      <VisitContentView visit={visit} patientId={params.id} />
    </div>
  );
}
