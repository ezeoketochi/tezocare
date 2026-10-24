"use client";

import { useParams, useRouter } from "next/navigation";
import { HeartPulse, Pencil, Plus, UserRound } from "lucide-react";
import { toast } from "sonner";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { TabsContent } from "@/components/ui/tabs";
import { DataTable, type DataTableColumn } from "@/components/common/data-table";
import { PillTabs } from "@/components/common/pill-tabs";
import { ProfileHero } from "@/components/common/profile-hero";
import { SettingValue } from "@/components/common/setting-value";
import { SettingsSection } from "@/components/common/settings-section";
import { useSession } from "@/lib/features/auth/hooks";
import { usePatient } from "@/lib/features/patients/hooks";
import { patientFullName, ageFromDob, type Patient } from "@/lib/features/patients/types";
import { useCreateVisit, usePatientMedications, usePatientVisits, usePatientVitalsHistory } from "@/lib/features/visits/hooks";
import type { PatientMedication, Visit, VitalsHistoryEntry } from "@/lib/features/visits/types";
import { can } from "@/lib/config/roles";
import { formatDate, formatDateTime } from "@/lib/utils/format";

const STATUS_VARIANT: Record<string, "default" | "secondary" | "outline" | "destructive"> = {
  active: "default",
  completed: "secondary",
  follow_up_pending: "outline",
  referred: "destructive",
};

function OverviewTab({ patient }: { patient: Patient }) {
  const address = [patient.address, patient.city, patient.state].filter(Boolean).join(", ");

  return (
    <div className="grid gap-5 lg:grid-cols-2">
      <Card>
        <CardContent>
          <SettingsSection icon={UserRound} title="Personal" divider={false}>
            <div className="grid gap-5 sm:grid-cols-2">
              <SettingValue label="Date of birth" value={formatDate(patient.date_of_birth)} />
              <SettingValue label="Age" value={ageFromDob(patient.date_of_birth) ?? "—"} />
              <SettingValue label="Gender" value={patient.gender} />
              <SettingValue label="Phone" value={patient.phone} />
              <SettingValue label="Occupation" value={patient.occupation} />
              <SettingValue label="Address" value={address} />
            </div>
          </SettingsSection>
        </CardContent>
      </Card>

      <Card>
        <CardContent>
          <SettingsSection icon={HeartPulse} title="Clinical background" divider={false}>
            <div className="grid gap-5 sm:grid-cols-2">
              <SettingValue label="Blood group" value={patient.blood_group} />
              <SettingValue label="Genotype" value={patient.genotype} />
              <SettingValue
                label="Allergies"
                value={
                  patient.allergies?.length ? (
                    <span className="flex flex-wrap gap-1">
                      {patient.allergies.map((a) => (
                        <Badge key={a} variant="destructive">
                          {a}
                        </Badge>
                      ))}
                    </span>
                  ) : (
                    "None recorded"
                  )
                }
              />
              <SettingValue
                label="Chronic conditions"
                value={
                  patient.chronic_conditions?.length ? (
                    <span className="flex flex-wrap gap-1">
                      {patient.chronic_conditions.map((c) => (
                        <Badge key={c}>{c}</Badge>
                      ))}
                    </span>
                  ) : (
                    "None recorded"
                  )
                }
              />
              <SettingValue
                label="Emergency contact"
                value={
                  patient.emergency_contact_name
                    ? `${patient.emergency_contact_name}${patient.emergency_contact_phone ? ` (${patient.emergency_contact_phone})` : ""}`
                    : undefined
                }
              />
              <SettingValue label="Registered" value={formatDateTime(patient.created_at)} />
            </div>
          </SettingsSection>
        </CardContent>
      </Card>
    </div>
  );
}

function VisitsTab({ patientId }: { patientId: string }) {
  const router = useRouter();
  const { staff } = useSession();
  const { data: visits, isPending, error, refetch } = usePatientVisits(patientId);
  const createVisit = useCreateVisit();

  const columns: DataTableColumn<Visit>[] = [
    { header: "#", cell: (v) => v.visit_number },
    { header: "Date", cell: (v) => formatDateTime(v.visit_date) },
    {
      header: "Diagnosis",
      cell: (v) => v.clinical_assessment?.suspected_diagnosis ?? "—",
    },
    {
      header: "Status",
      cell: (v) => <Badge variant={STATUS_VARIANT[v.status] ?? "outline"}>{v.status?.replace(/_/g, " ")}</Badge>,
    },
  ];

  return (
    <div className="grid gap-4">
      {can(staff?.role, "visitCreate") && (
        <Button
          size="sm"
          className="self-start"
          disabled={createVisit.isPending}
          onClick={() =>
            createVisit.mutate(
              { patient_id: patientId },
              {
                onSuccess: (visit) => router.push(`/patients/${patientId}/visits/${visit.id}/edit`),
                onError: (err) => toast.error(err instanceof Error ? err.message : "Could not start visit"),
              }
            )
          }
        >
          <Plus className="size-4" /> {createVisit.isPending ? "Starting…" : "New visit"}
        </Button>
      )}
      <DataTable
        columns={columns}
        rows={visits ?? []}
        rowKey={(v) => v.id}
        onRowClick={(v) => router.push(`/patients/${patientId}/visits/${v.id}`)}
        isLoading={isPending}
        error={error}
        onRetry={() => refetch()}
        emptyTitle="No visits yet"
        emptyDescription="Start a visit to record clinical details."
      />
    </div>
  );
}

function MedicationsTab({ patientId }: { patientId: string }) {
  const { data: meds, isPending, error, refetch } = usePatientMedications(patientId);

  const columns: DataTableColumn<PatientMedication>[] = [
    { header: "Drug", cell: (m) => m.drug_name },
    {
      header: "Dose",
      cell: (m) => [m.dose_amount ? `${m.dose_amount}${m.dose_unit ?? ""}` : null, m.frequency, m.route].filter(Boolean).join(" · ") || "—",
    },
    { header: "Dispensed", cell: (m) => formatDate(m.date_dispensed) },
    { header: "Refill due", cell: (m) => formatDate(m.refill_date) },
  ];

  return (
    <DataTable
      columns={columns}
      rows={meds ?? []}
      rowKey={(m) => `${m.visit_id}-${m.drug_name}-${m.date_dispensed ?? ""}`}
      isLoading={isPending}
      error={error}
      onRetry={() => refetch()}
      emptyTitle="No medications recorded"
      emptyDescription="Medications appear here once dispensed during a visit."
    />
  );
}

function VitalsTab({ patientId }: { patientId: string }) {
  const router = useRouter();
  const { data: history, isPending, error, refetch } = usePatientVitalsHistory(patientId);

  const columns: DataTableColumn<VitalsHistoryEntry>[] = [
    { header: "Date", cell: (v) => formatDate(v.visit_date) },
    { header: "BP", cell: (v) => (v.bp_systolic ? `${v.bp_systolic}/${v.bp_diastolic ?? "—"}` : "—") },
    { header: "HR", cell: (v) => v.heart_rate ?? "—" },
    { header: "Temp °C", cell: (v) => v.temperature ?? "—" },
    { header: "SpO₂", cell: (v) => (v.sp_o2 ? `${v.sp_o2}%` : "—") },
    { header: "Weight kg", cell: (v) => v.weight ?? "—" },
    { header: "BMI", cell: (v) => v.bmi ?? "—" },
  ];

  return (
    <DataTable
      columns={columns}
      rows={history ?? []}
      rowKey={(v) => v.visit_id}
      onRowClick={(v) => router.push(`/patients/${patientId}/visits/${v.visit_id}`)}
      isLoading={isPending}
      error={error}
      onRetry={() => refetch()}
      emptyTitle="No vitals recorded"
    />
  );
}

export default function PatientDetailPage() {
  const params = useParams<{ id: string }>();
  const router = useRouter();
  const { staff } = useSession();
  const { data: patient, isPending, error } = usePatient(params.id);

  if (isPending) {
    return (
      <div className="grid gap-5">
        <Skeleton className="h-[185px] w-full" />
        <Skeleton className="h-64 w-full" />
      </div>
    );
  }
  if (error || !patient) return <p className="text-sm text-muted-foreground">Patient not found.</p>;

  return (
    <div className="grid gap-5">
      <ProfileHero
        name={patientFullName(patient)}
        subtitle={`${[patient.gender, patient.phone].filter(Boolean).join(" · ")}`}
        tag={`${ageFromDob(patient.date_of_birth) ?? "?"} yrs`}
        actions={
          can(staff?.role, "patientEdit") && (
            <Button variant="ghost" onClick={() => router.push(`/patients/${patient.id}/edit`)}>
              <Pencil data-icon="inline-start" /> Edit
            </Button>
          )
        }
      />

      <PillTabs
        ariaLabel="Patient record"
        defaultValue="overview"
        tabs={[
          { value: "overview", label: "Overview" },
          { value: "visits", label: "Visits" },
          { value: "medications", label: "Medications" },
          { value: "vitals", label: "Vitals" },
        ]}
      >
        <TabsContent value="overview">
          <OverviewTab patient={patient} />
        </TabsContent>
        <TabsContent value="visits">
          <VisitsTab patientId={patient.id} />
        </TabsContent>
        <TabsContent value="medications">
          <MedicationsTab patientId={patient.id} />
        </TabsContent>
        <TabsContent value="vitals">
          <VitalsTab patientId={patient.id} />
        </TabsContent>
      </PillTabs>
    </div>
  );
}
