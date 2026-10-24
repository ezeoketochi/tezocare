"use client";

import { Suspense, useMemo, useState } from "react";
import { useRouter } from "next/navigation";
import { useSearchParams } from "next/navigation";
import { Pill, Search } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { DataTable, type DataTableColumn } from "@/components/common/data-table";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { AlertCircle } from "lucide-react";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Skeleton } from "@/components/ui/skeleton";
import { useDebounce } from "@/lib/hooks/use-debounce";
import { usePatients } from "@/lib/features/patients/hooks";
import { patientFullName, type Patient } from "@/lib/features/patients/types";
import { usePatientMedications } from "@/lib/features/visits/hooks";
import type { PatientMedication } from "@/lib/features/visits/types";
import { getErrorMessage } from "@/lib/api/errors";
import { formatDate } from "@/lib/utils/format";

function MedicationsView() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const [search, setSearch] = useState("");
  const debouncedSearch = useDebounce(search, 300);
  const selectedParam = searchParams.get("patient") ?? "";
  const [picked, setPicked] = useState<string | null>(null);
  const patientId = picked ?? (selectedParam || null);

  const { data: results, isPending: searching } = usePatients(
    useMemo(
      () => ({ skip: 0, limit: 8, search: debouncedSearch || undefined }),
      [debouncedSearch]
    )
  );

  const medsQuery = usePatientMedications(patientId ?? undefined);
  const selectedPatient = results?.items?.find((p) => p.id === patientId);

  const columns: DataTableColumn<PatientMedication>[] = [
    { header: "Drug", cell: (m) => <span className="font-medium">{m.drug_name}</span> },
    {
      header: "Sig",
      cell: (m) =>
        [m.dose_amount ? `${m.dose_amount}${m.dose_unit ?? ""}` : null, m.route, m.frequency]
          .filter(Boolean)
          .join(" · ") || "—",
    },
    {
      header: "Duration",
      cell: (m) => (m.duration_amount ? `${m.duration_amount} ${m.duration_unit ?? ""}`.trim() : "—"),
    },
    { header: "Dispensed", cell: (m) => formatDate(m.date_dispensed) },
    { header: "Expected finish", cell: (m) => formatDate(m.expected_finish_date) },
    { header: "Refill due", cell: (m) => formatDate(m.refill_date) },
    { header: "Prescribed by", cell: (m) => m.prescribed_by ?? "—" },
  ];

  function selectPatient(p: Patient) {
    setPicked(p.id);
    router.replace(`/medications?patient=${p.id}`, { scroll: false });
  }

  return (
    <div className="grid gap-5">
      <PageHeader
        title="Medications"
        description="Dispensed medications per patient, derived from visit records."
      />

      <div className="grid gap-4 lg:grid-cols-[minmax(0,20rem)_1fr]">
        <Card className="h-fit">
          <CardHeader>
            <CardTitle className="text-base">Find a patient</CardTitle>
          </CardHeader>
          <CardContent className="space-y-3">
            <div className="relative">
              <Search className="pointer-events-none absolute left-2.5 top-1/2 size-4 -translate-y-1/2 text-muted-foreground" />
              <Input
                value={search}
                onChange={(e) => setSearch(e.target.value)}
                placeholder="Search by name…"
                className="pl-8"
                aria-label="Search patients"
              />
            </div>
            {patientId && selectedPatient && (
              <p className="text-sm">
                Selected: <span className="font-medium">{patientFullName(selectedPatient)}</span>
              </p>
            )}
            {patientId && !selectedPatient && picked === null && (
              <p className="text-sm text-muted-foreground">Showing medications for the linked patient.</p>
            )}
            {searching && !debouncedSearch ? (
              <div className="space-y-2">
                {Array.from({ length: 4 }).map((_, i) => (
                  <Skeleton key={i} className="h-9 w-full" />
                ))}
              </div>
            ) : (results?.items?.length ?? 0) === 0 ? (
              <p className="text-sm text-muted-foreground">{debouncedSearch ? "No patients match." : "Type to search patients."}</p>
            ) : (
              <ul className="divide-y">
                {results!.items.map((p) => (
                  <li key={p.id}>
                    <Button
                      type="button"
                      variant="ghost"
                      className={`h-auto w-full justify-start py-2 ${patientId === p.id ? "bg-muted" : ""}`}
                      onClick={() => selectPatient(p)}
                    >
                      <span className="min-w-0">
                        <span className="block truncate text-sm font-medium">{patientFullName(p)}</span>
                        <span className="block truncate text-xs text-muted-foreground">{p.phone ?? "No phone"}</span>
                      </span>
                    </Button>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <div>
          {!patientId ? (
            <div className="flex flex-col items-center justify-center gap-2 rounded-card border border-dashed border-line py-16 text-center">
              <Pill className="size-8 text-muted-foreground" />
              <p className="font-medium">Select a patient</p>
              <p className="max-w-sm text-sm text-muted-foreground">
                Search for a patient on the left to see every medication dispensed across their visits.
              </p>
            </div>
          ) : medsQuery.error ? (
            <Alert variant="destructive">
              <AlertCircle />
              <AlertTitle>Could not load medications</AlertTitle>
              <AlertDescription className="flex flex-wrap items-center justify-between gap-2">
                <span>{getErrorMessage(medsQuery.error)}</span>
                <Button size="sm" variant="outline" onClick={() => medsQuery.refetch()}>
                  Retry
                </Button>
              </AlertDescription>
            </Alert>
          ) : (
            <DataTable
              columns={columns}
              rows={medsQuery.data ?? []}
              rowKey={(m) => `${m.visit_id}-${m.drug_name}-${m.date_dispensed ?? ""}`}
              isLoading={medsQuery.isPending}
              onRowClick={(m) => router.push(`/patients/${patientId}/visits/${m.visit_id}`)}
              emptyTitle="No medications recorded"
              emptyDescription="Medications appear here once dispensed during a visit."
            />
          )}
        </div>
      </div>
    </div>
  );
}

export default function MedicationsPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <MedicationsView />
    </Suspense>
  );
}
