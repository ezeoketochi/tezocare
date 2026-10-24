"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { useForm } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { Phone } from "lucide-react";
import { z } from "zod";
import { PageHeader } from "@/components/common/page-header";
import { DataTable, type DataTableColumn } from "@/components/common/data-table";
import { PillTabs } from "@/components/common/pill-tabs";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
} from "@/components/ui/dialog";
import { FieldError, Form, FormControl, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { TabsContent } from "@/components/ui/tabs";
import { Textarea } from "@/components/ui/textarea";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { can } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";
import { useDueFollowups } from "@/lib/features/follow-ups/hooks";
import type { DueFollowup } from "@/lib/features/follow-ups/types";
import { FOLLOWUP_STATUS_LABELS } from "@/lib/features/follow-ups/types";
import { useFollowUpDone } from "@/lib/features/visits/action-hooks";
import { normalizePhone } from "@/lib/features/refills/types";
import { formatDate } from "@/lib/utils/format";

type StatusFilter = "all" | "overdue" | "due_today" | "upcoming";

const doneSchema = z.object({ outcome: z.string().min(1, "Outcome is required") });

function statusVariant(status: string): "default" | "secondary" | "outline" | "destructive" {
  if (status === "overdue") return "destructive";
  if (status === "due_today") return "default";
  return "outline";
}

function scheduledLabel(f: DueFollowup): { text: string; className: string } {
  const days = f.days_until_followup;
  if (days < 0)
    return {
      text: `${Math.abs(days)} day${days === -1 ? "" : "s"} overdue`,
      className: "font-medium text-destructive",
    };
  if (days === 0) return { text: "Due today", className: "font-medium" };
  return { text: `In ${days} day${days === 1 ? "" : "s"}`, className: "text-muted-foreground" };
}

export default function FollowUpsPage() {
  const router = useRouter();
  const { staff } = useSession();
  const canAct = can(staff?.role, "followupAction");
  const { data, isLoading, error, refetch } = useDueFollowups();
  const [tab, setTab] = useState<StatusFilter>("all");
  const [active, setActive] = useState<DueFollowup | null>(null);

  const doneForm = useForm<{ outcome: string }>({
    resolver: zodResolver(doneSchema),
    defaultValues: { outcome: "" },
  });
  const followUpDone = useFollowUpDone();

  const followups = useMemo(() => data?.followups ?? [], [data]);
  const filtered = useMemo(
    () => (tab === "all" ? followups : followups.filter((f) => f.followup_status === tab)),
    [followups, tab]
  );

  const columns: DataTableColumn<DueFollowup>[] = useMemo(
    () => [
      {
        header: "Patient",
        cell: (f) => (
          <div>
            <div className="font-medium">{f.patient_name}</div>
            <div className="text-xs text-muted-foreground">{f.patient_phone ?? "No phone"}</div>
          </div>
        ),
      },
      {
        header: "Scheduled",
        cell: (f) => {
          const label = scheduledLabel(f);
          return (
            <div>
              <div>{formatDate(f.scheduled_date)}</div>
              <div className={`text-xs ${label.className}`}>{label.text}</div>
            </div>
          );
        },
      },
      {
        header: "Status",
        cell: (f) => (
          <Badge variant={statusVariant(f.followup_status)}>{FOLLOWUP_STATUS_LABELS[f.followup_status] ?? f.followup_status}</Badge>
        ),
      },
      {
        header: "Diagnosis",
        cell: (f) => (
          <div className="max-w-44">
            <div className="truncate">{f.suspected_diagnosis ?? "—"}</div>
            <div className="truncate text-xs text-muted-foreground">Visit {formatDate(f.visit_date)}</div>
          </div>
        ),
        mobilePrimary: (f) => f.suspected_diagnosis ?? "—",
      },
      {
        header: "Attending",
        cell: (f) => f.attending_staff ?? "—",
      },
      {
        header: "Actions",
        className: "text-right",
        cell: (f) => (
          <div className="flex flex-wrap items-center justify-end gap-1" onClick={(e) => e.stopPropagation()}>
            {f.patient_phone && (
              <Tooltip>
                <TooltipTrigger
                  render={
                    <Button
                      type="button"
                      size="icon-sm"
                      variant="ghost"
                      aria-label="Call patient"
                      render={<a href={`tel:${normalizePhone(f.patient_phone)}`} />}
                    />
                  }
                >
                  <Phone />
                </TooltipTrigger>
                <TooltipContent>Call patient</TooltipContent>
              </Tooltip>
            )}
            {canAct && (
              <Button
                type="button"
                size="xs"
                variant="outline"
                onClick={(e) => {
                  e.stopPropagation();
                  doneForm.reset({ outcome: "" });
                  setActive(f);
                }}
              >
                Mark done
              </Button>
            )}
          </div>
        ),
      },
    ],
    [canAct, doneForm]
  );

  return (
    <div className="grid gap-5">
      <PageHeader
        title="Follow-ups"
        description="Open follow-ups from active and pending visits, ordered by scheduled date."
      />

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Card size="sm">
          <CardContent>
            <p className="text-xs leading-[16px] text-muted-foreground">Total open</p>
            <p className="text-[24px] leading-[30px] font-semibold text-title">{data?.total ?? "—"}</p>
          </CardContent>
        </Card>
        <Card size="sm">
          <CardContent>
            <p className="text-xs leading-[16px] text-muted-foreground">Overdue</p>
            <p className="text-[24px] leading-[30px] font-semibold text-danger">{data?.overdue ?? "—"}</p>
          </CardContent>
        </Card>
        <Card size="sm">
          <CardContent>
            <p className="text-xs leading-[16px] text-muted-foreground">Due today</p>
            <p className="text-[24px] leading-[30px] font-semibold text-title">{data?.due_today ?? "—"}</p>
          </CardContent>
        </Card>
        <Card size="sm">
          <CardContent>
            <p className="text-xs leading-[16px] text-muted-foreground">Upcoming</p>
            <p className="text-[24px] leading-[30px] font-semibold text-title">{data?.upcoming ?? "—"}</p>
          </CardContent>
        </Card>
      </div>

      <PillTabs
        ariaLabel="Filter follow-ups by status"
        value={tab}
        onValueChange={(value) => setTab(value as StatusFilter)}
        tabs={[
          { value: "all", label: `All (${data?.total ?? 0})` },
          { value: "overdue", label: `Overdue (${data?.overdue ?? 0})` },
          { value: "due_today", label: `Due today (${data?.due_today ?? 0})` },
          { value: "upcoming", label: `Upcoming (${data?.upcoming ?? 0})` },
        ]}
      >
        {(["all", "overdue", "due_today", "upcoming"] as const).map((value) => (
          <TabsContent key={value} value={value}>
            {tab === value && (
              <DataTable
                columns={columns}
                rows={filtered}
                rowKey={(f) => f.visit_id}
                isLoading={isLoading}
                error={error}
                onRetry={() => refetch()}
                onRowClick={(f) => router.push(`/patients/${f.patient_id}/visits/${f.visit_id}`)}
                emptyTitle="Nothing to follow up"
                emptyDescription="Follow-ups appear when a visit schedules one and hasn't been marked done yet."
              />
            )}
          </TabsContent>
        ))}
      </PillTabs>

      <Dialog open={active !== null} onOpenChange={(open) => !open && setActive(null)}>
        <DialogContent>
          <DialogHeader>
            <DialogTitle>Record follow-up outcome</DialogTitle>
            <DialogDescription>
              {active?.patient_name} — scheduled {formatDate(active?.scheduled_date)}
            </DialogDescription>
          </DialogHeader>
          <Form {...doneForm}>
            <form
              onSubmit={doneForm.handleSubmit((values) =>
                active &&
                followUpDone.mutate(
                  { id: active.visit_id, outcome: values.outcome },
                  { onSuccess: () => setActive(null) }
                )
              )}
              className="space-y-4"
            >
              <FormField
                control={doneForm.control}
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
                <Button type="button" variant="outline" onClick={() => setActive(null)}>
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
