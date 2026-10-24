"use client";

import { useState } from "react";
import { useRouter } from "next/navigation";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { format, parseISO } from "date-fns";
import {
  Activity,
  ArrowUpRight,
  CalendarClock,
  CheckCircle2,
  FlaskConical,
  Lightbulb,
  MessageSquareText,
  Pill,
  Send,
  Stethoscope,
  Trash2,
} from "lucide-react";
import { z } from "zod";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { Input } from "@/components/ui/input";
import { Textarea } from "@/components/ui/textarea";
import { ConfirmDialog } from "@/components/common/confirm-dialog";
import { FieldError, Form, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { Skeleton } from "@/components/ui/skeleton";
import { can } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";
import { useCompleteVisit, useDeleteVisit, useFollowUpDone, useReferVisit } from "@/lib/features/visits/action-hooks";
import type { Visit } from "@/lib/features/visits/types";

const STATUS_VARIANT: Record<string, "default" | "secondary" | "outline" | "destructive"> = {
  active: "default",
  completed: "secondary",
  follow_up_pending: "outline",
  referred: "destructive",
};

const referSchema = z.object({
  destination: z.string().min(1, "Destination is required"),
  reason: z.string().min(1, "Reason is required"),
});

const outcomeSchema = z.object({ outcome: z.string().min(1, "Outcome is required") });

function fmtDate(value: string | null | undefined) {
  if (!value) return "—";
  try {
    return format(parseISO(value), "MMM d, yyyy");
  } catch {
    return value;
  }
}

function fmtDateTime(value: string | null | undefined) {
  if (!value) return "—";
  try {
    return format(parseISO(value), "MMM d, yyyy 'at' h:mm a");
  } catch {
    return value;
  }
}

function Section({
  icon,
  title,
  children,
}: {
  icon?: React.ComponentType<{ className?: string }>;
  title: string;
  children: React.ReactNode;
}) {
  return (
    <Card>
      <CardHeader>
        <CardTitle icon={icon}>{title}</CardTitle>
      </CardHeader>
      <CardContent className="space-y-2 text-sm">{children}</CardContent>
    </Card>
  );
}

export function VisitContentView({ visit, patientId }: { visit: Visit; patientId: string }) {
  const router = useRouter();
  const { staff } = useSession();
  const completeVisit = useCompleteVisit();
  const referMutation = useReferVisit();
  const followUpDone = useFollowUpDone();
  const deleteVisit = useDeleteVisit();
  const [referOpen, setReferOpen] = useState(false);
  const [followUpOpen, setFollowUpOpen] = useState(false);

  const referForm = useForm<z.infer<typeof referSchema>>({
    resolver: zodResolver(referSchema),
    defaultValues: { destination: "", reason: "" },
  });
  const outcomeForm = useForm<z.infer<typeof outcomeSchema>>({
    resolver: zodResolver(outcomeSchema),
    defaultValues: { outcome: "" },
  });

  const isCreator = staff?.id === visit.staff_id;
  const canModify = isCreator && visit.status === "active";

  const vitals = visit.vitals;
  const hasVitals = vitals && Object.entries(vitals).some(([k, v]) => v != null && k !== "blood_glucose_type");

  return (
    <div className="grid gap-5">
      <div className="flex flex-wrap items-center gap-2">
        <Badge variant={STATUS_VARIANT[visit.status] ?? "outline"}>{visit.status?.replace(/_/g, " ")}</Badge>
        <span className="text-sm text-muted-foreground">Visit #{visit.visit_number} · {fmtDateTime(visit.visit_date)}</span>
        <div className="ml-auto flex flex-wrap gap-2">
          {canModify && (
            <Button size="sm" onClick={() => router.push(`/patients/${patientId}/visits/${visit.id}/edit`)}>
              Edit
            </Button>
          )}
          {canModify && can(staff?.role, "visitComplete") && (
            <Button
              size="sm"
              variant="outline"
              disabled={completeVisit.isPending}
              onClick={() => completeVisit.mutate(visit.id)}
            >
              <CheckCircle2 className="size-4" /> {completeVisit.isPending ? "Completing…" : "Complete"}
            </Button>
          )}
          {canModify && !visit.referral?.is_referred && (
            <Button size="sm" variant="outline" onClick={() => setReferOpen(true)}>
              <ArrowUpRight className="size-4" /> Refer
            </Button>
          )}
          {canModify && (
            <ConfirmDialog
              destructive
              title="Delete this visit?"
              description="This permanently removes the visit and its dispensed medications. This cannot be undone."
              confirmLabel="Delete"
              pending={deleteVisit.isPending}
              onConfirm={() =>
                deleteVisit
                  .mutateAsync({ id: visit.id, patientId })
                  .then(() => router.push(`/patients/${patientId}`))
              }
              trigger={
                <Button size="sm" variant="destructive">
                  <Trash2 data-icon="inline-start" /> Delete
                </Button>
              }
            />
          )}
          {visit.follow_up?.required && !visit.follow_up?.is_done && can(staff?.role, "followupAction") && (
            <Button size="sm" variant="outline" onClick={() => setFollowUpOpen(true)}>
              Mark follow-up done
            </Button>
          )}
        </div>
      </div>

      {visit.chief_complaints?.length > 0 && (
        <Section icon={MessageSquareText} title="Chief complaints">
          <ul className="list-disc space-y-1 pl-5">
            {visit.chief_complaints.map((c, i) => (
              <li key={i}>
                {c.complaint} {c.duration && <span className="text-muted-foreground">({c.duration})</span>}
              </li>
            ))}
          </ul>
        </Section>
      )}

      {(visit.medication_history?.past_medications?.length ||
        visit.medication_history?.current_medications?.length ||
        visit.medication_history?.adherence) && (
        <Section icon={Pill} title="Medication history">
          {visit.medication_history.past_medications?.length > 0 && (
            <p>
              <span className="text-muted-foreground">Past: </span>
              {visit.medication_history.past_medications.join(", ")}
            </p>
          )}
          {visit.medication_history.current_medications?.length > 0 && (
            <p>
              <span className="text-muted-foreground">Current: </span>
              {visit.medication_history.current_medications.join(", ")}
            </p>
          )}
          {visit.medication_history.adherence && (
            <p>
              <span className="text-muted-foreground">Adherence: </span>
              {visit.medication_history.adherence}
              {visit.medication_history.non_adherence_reason && ` — ${visit.medication_history.non_adherence_reason}`}
            </p>
          )}
        </Section>
      )}

      {hasVitals && (
        <Section icon={Activity} title="Vitals">
          <div className="grid grid-cols-2 gap-x-6 gap-y-2 sm:grid-cols-4">
            {[
              ["BP", vitals.bp_systolic ? `${vitals.bp_systolic}/${vitals.bp_diastolic ?? "—"}` : null],
              ["Heart rate", vitals.heart_rate ? `${vitals.heart_rate} bpm` : null],
              ["Temperature", vitals.temperature ? `${vitals.temperature} °C` : null],
              ["SpO₂", vitals.sp_o2 ? `${vitals.sp_o2}%` : null],
              ["Resp. rate", vitals.respiratory_rate ? `${vitals.respiratory_rate}/min` : null],
              ["Weight", vitals.weight ? `${vitals.weight} kg` : null],
              ["Height", vitals.height ? `${vitals.height} cm` : null],
              ["BMI", vitals.bmi ?? null],
              [
                "Glucose",
                vitals.blood_glucose ? `${vitals.blood_glucose} ${vitals.blood_glucose_type ?? ""}`.trim() : null,
              ],
            ]
              .filter(([, v]) => v != null)
              .map(([label, v]) => (
                <div key={label as string}>
                  <div className="text-xs text-muted-foreground">{label}</div>
                  <div className="font-medium">{v as string}</div>
                </div>
              ))}
          </div>
        </Section>
      )}

      {visit.test_results?.length > 0 && (
        <Section icon={FlaskConical} title="Test results">
          {visit.test_results.map((t, i) => (
            <p key={i}>
              <span className="font-medium">{t.test_name}:</span> {t.result}
            </p>
          ))}
        </Section>
      )}

      {(visit.clinical_assessment?.suspected_diagnosis || visit.clinical_assessment?.pharmacist_notes) && (
        <Section icon={Stethoscope} title="Clinical assessment">
          {visit.clinical_assessment.suspected_diagnosis && (
            <p>
              <span className="text-muted-foreground">Suspected diagnosis: </span>
              <span className="font-medium">{visit.clinical_assessment.suspected_diagnosis}</span>
            </p>
          )}
          {visit.clinical_assessment.severity && (
            <p>
              <span className="text-muted-foreground">Severity: </span>
              {visit.clinical_assessment.severity}
            </p>
          )}
          {visit.clinical_assessment.pharmacist_notes && <p className="whitespace-pre-wrap">{visit.clinical_assessment.pharmacist_notes}</p>}
        </Section>
      )}

      {visit.medications_dispensed?.length > 0 && (
        <Section icon={Pill} title="Medications dispensed">
          <div className="overflow-x-auto">
            <table className="w-full text-sm">
              <thead>
                <tr className="border-b text-left text-xs text-muted-foreground">
                  <th className="py-2 pr-3 font-medium">Drug</th>
                  <th className="py-2 pr-3 font-medium">Dose</th>
                  <th className="py-2 pr-3 font-medium">Frequency</th>
                  <th className="py-2 pr-3 font-medium">Duration</th>
                  <th className="py-2 pr-3 font-medium">Refill due</th>
                  <th className="py-2 font-medium">Instructions</th>
                </tr>
              </thead>
              <tbody>
                {visit.medications_dispensed.map((m, i) => (
                  <tr key={i} className="border-b last:border-0">
                    <td className="py-2 pr-3 font-medium">{m.drug_name}</td>
                    <td className="py-2 pr-3">
                      {m.dose_amount ? `${m.dose_amount}${m.dose_unit ?? ""}` : "—"} {m.route && `· ${m.route}`}
                    </td>
                    <td className="py-2 pr-3">{m.frequency || m.frequency_code || "—"}</td>
                    <td className="py-2 pr-3">
                      {m.duration_amount ? `${m.duration_amount} ${m.duration_unit ?? ""}` : "—"}
                    </td>
                    <td className="py-2 pr-3">{fmtDate(m.refill_date)}</td>
                    <td className="py-2 text-muted-foreground">{m.instructions ?? "—"}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Section>
      )}

      {visit.counselling_advice && (
        <Section icon={Lightbulb} title="Counselling advice">
          <p className="whitespace-pre-wrap">{visit.counselling_advice}</p>
        </Section>
      )}

      {visit.follow_up?.required && (
        <Section icon={CalendarClock} title="Follow-up">
          <p>
            Scheduled: <span className="font-medium">{fmtDate(visit.follow_up.scheduled_date)}</span>
            {visit.follow_up.is_recurrent && visit.follow_up.recurrence_interval_days
              ? ` · repeats every ${visit.follow_up.recurrence_interval_days} days`
              : ""}
          </p>
          {visit.follow_up.is_done ? (
            <p className="text-muted-foreground">
              Done {fmtDate(visit.follow_up.date_completed)} — outcome: {visit.follow_up.outcome ?? "—"}
            </p>
          ) : (
            <p className="text-gold">Pending</p>
          )}
        </Section>
      )}

      {visit.referral?.is_referred && (
        <Section icon={Send} title="Referral">
          <p>
            Referred to <span className="font-medium">{visit.referral.destination}</span>
          </p>
          {visit.referral.reason && <p className="text-muted-foreground">Reason: {visit.referral.reason}</p>}
        </Section>
      )}

      <Dialog open={referOpen} onOpenChange={setReferOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Refer patient</DialogTitle>
            <DialogDescription>This marks the visit as referred.</DialogDescription>
          </DialogHeader>
          <Form {...referForm}>
            <form
              onSubmit={referForm.handleSubmit((values) =>
                referMutation.mutate(
                  { id: visit.id, ...values },
                  { onSuccess: () => setReferOpen(false) }
                )
              )}
              className="space-y-4"
            >
              <FormField
                control={referForm.control}
                name="destination"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Destination</FormLabel>
                    <FormControl>
                      <Input placeholder="Hospital or clinic" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <FormField
                control={referForm.control}
                name="reason"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Reason</FormLabel>
                    <FormControl>
                      <Textarea rows={3} {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setReferOpen(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={referMutation.isPending}>
                  {referMutation.isPending ? "Referring…" : "Refer"}
                </Button>
              </DialogFooter>
            </form>
          </Form>
        </DialogContent>
      </Dialog>

      <Dialog open={followUpOpen} onOpenChange={setFollowUpOpen}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Record follow-up outcome</DialogTitle>
          </DialogHeader>
          <Form {...outcomeForm}>
            <form
              onSubmit={outcomeForm.handleSubmit((values) =>
                followUpDone.mutate(
                  { id: visit.id, outcome: values.outcome },
                  { onSuccess: () => setFollowUpOpen(false) }
                )
              )}
              className="space-y-4"
            >
              <FormField
                control={outcomeForm.control}
                name="outcome"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Outcome</FormLabel>
                    <FormControl>
                      <Textarea rows={3} placeholder="What happened at the follow-up?" {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
              <DialogFooter>
                <Button type="button" variant="outline" onClick={() => setFollowUpOpen(false)}>
                  Cancel
                </Button>
                <Button type="submit" disabled={followUpDone.isPending}>
                  {followUpDone.isPending ? "Saving…" : "Save"}
                </Button>
              </DialogFooter>
            </form>
          </Form>
        </DialogContent>
      </Dialog>
    </div>
  );
}

export function VisitLoading() {
  return (
    <div className="grid gap-5">
      <Skeleton className="h-8 w-64" />
      <Skeleton className="h-40 w-full" />
      <Skeleton className="h-40 w-full" />
    </div>
  );
}
