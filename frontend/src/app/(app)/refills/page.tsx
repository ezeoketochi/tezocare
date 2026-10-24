"use client";

import { useRouter } from "next/navigation";
import { useMemo, useState } from "react";
import { Check, MessageSquare, Phone, RefreshCw, Send } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { DataTable, type DataTableColumn } from "@/components/common/data-table";
import { PillTabs } from "@/components/common/pill-tabs";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { TabsContent } from "@/components/ui/tabs";
import { Tooltip, TooltipContent, TooltipTrigger } from "@/components/ui/tooltip";
import { can } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";
import { useRefills, useContactRefill, useFulfillRefill } from "@/lib/features/refills/hooks";
import {
  ESCALATION_PHASES,
  phaseBadgeVariant,
  refillReminderMessage,
  whatsappUrl,
  type Refill,
} from "@/lib/features/refills/types";
import { formatDate } from "@/lib/utils/format";

type PhaseFilter = "all" | "outreach" | "dueToday" | "overdue";

const PHASE_BY_FILTER: Record<Exclude<PhaseFilter, "all">, string> = {
  outreach: ESCALATION_PHASES.outreach,
  dueToday: ESCALATION_PHASES.dueToday,
  overdue: ESCALATION_PHASES.overdue,
};

function dueLabel(refill: Refill): { text: string; className: string } {
  if (refill.refill_status === "completed") return { text: "Fulfilled", className: "text-muted-foreground" };
  const days = refill.days_until_refill;
  if (days < 0)
    return {
      text: `${Math.abs(days)} day${days === -1 ? "" : "s"} overdue`,
      className: "font-medium text-destructive",
    };
  if (days === 0) return { text: "Due today", className: "font-medium" };
  return { text: `Due in ${days} day${days === 1 ? "" : "s"}`, className: "text-muted-foreground" };
}

function ContactBadge({ status }: { status: string }) {
  if (status === "contacted") return <Badge variant="secondary">Contacted</Badge>;
  return <Badge variant="outline">Pending</Badge>;
}

function LinkButton({ href, label, children }: { href: string; label: string; children: React.ReactNode }) {
  return (
    <Tooltip>
      <TooltipTrigger
        render={
          <Button
            type="button"
            size="icon-sm"
            variant="ghost"
            aria-label={label}
            render={<a href={href} target={href.startsWith("http") ? "_blank" : undefined} rel="noreferrer" />}
          />
        }
      >
        {children}
      </TooltipTrigger>
      <TooltipContent>{label}</TooltipContent>
    </Tooltip>
  );
}

function RefillActions({ refill, canAct }: { refill: Refill; canAct: boolean }) {
  const contactMutation = useContactRefill();
  const fulfillMutation = useFulfillRefill();
  const phone = refill.patient_phone;
  const message = refillReminderMessage(refill);

  return (
    <div className="flex flex-wrap items-center justify-end gap-1" onClick={(e) => e.stopPropagation()}>
      {phone && (
        <LinkButton href={`tel:${phone}`} label="Call patient">
          <Phone />
        </LinkButton>
      )}
      {phone && (
        <LinkButton href={`sms:${phone}?body=${encodeURIComponent(message)}`} label="Send SMS reminder">
          <MessageSquare />
        </LinkButton>
      )}
      {phone && (
        <LinkButton href={whatsappUrl(phone, message)} label="Send on WhatsApp">
          <Send />
        </LinkButton>
      )}
      {canAct && refill.contact_status === "pending" && (
        <Tooltip>
          <TooltipTrigger
            render={
              <Button
                type="button"
                size="icon-sm"
                variant="ghost"
                aria-label="Mark contacted"
                disabled={contactMutation.isPending}
                onClick={() => contactMutation.mutate(refill.id)}
              />
            }
          >
            <Check />
          </TooltipTrigger>
          <TooltipContent>Mark contacted</TooltipContent>
        </Tooltip>
      )}
      {canAct && refill.refill_status !== "completed" && (
        <Button
          type="button"
          size="xs"
          variant="outline"
          disabled={fulfillMutation.isPending}
          onClick={(e) => {
            e.stopPropagation();
            fulfillMutation.mutate(refill.id);
          }}
        >
          Fulfilled
        </Button>
      )}
    </div>
  );
}

function buildColumns(canAct: boolean): DataTableColumn<Refill>[] {
  return [
    {
      header: "Patient",
      cell: (r) => (
        <div>
          <div className="font-medium">{r.patient_name}</div>
          <div className="text-xs text-muted-foreground">{r.patient_phone ?? "No phone"}</div>
        </div>
      ),
    },
    {
      header: "Medication",
      cell: (r) => (
        <div className="max-w-56">
          <div className="truncate font-medium">{r.drug_name}</div>
          {r.sig_string && <div className="truncate text-xs text-muted-foreground">{r.sig_string}</div>}
        </div>
      ),
      mobilePrimary: (r) => r.drug_name,
    },
    {
      header: "Refill date",
      cell: (r) => {
        const label = dueLabel(r);
        return (
          <div>
            <div>{formatDate(r.refill_date)}</div>
            <div className={`text-xs ${label.className}`}>{label.text}</div>
          </div>
        );
      },
    },
    {
      header: "Phase",
      cell: (r) => <Badge variant={phaseBadgeVariant(r.escalated_status)}>{r.escalated_status}</Badge>,
    },
    { header: "Contact", cell: (r) => <ContactBadge status={r.contact_status} /> },
    {
      header: "Status",
      cell: (r) =>
        r.refill_status === "completed" ? (
          <Badge variant="secondary">Completed</Badge>
        ) : r.refill_status === "overdue" ? (
          <Badge variant="destructive">Overdue</Badge>
        ) : (
          <Badge variant="outline">Pending</Badge>
        ),
    },
    {
      header: "Actions",
      className: "text-right",
      cell: (r) => <RefillActions refill={r} canAct={canAct} />,
    },
  ];
}

export default function RefillsPage() {
  const router = useRouter();
  const { staff } = useSession();
  const canAct = can(staff?.role, "refillAction");
  const { data, isLoading, error, refetch, isFetching } = useRefills();
  const [tab, setTab] = useState<PhaseFilter>("all");

  const refills = useMemo(() => data?.refills ?? [], [data]);
  const filtered = useMemo(() => {
    if (tab === "all") return refills;
    const phase = PHASE_BY_FILTER[tab];
    return refills.filter((r) => r.escalated_status === phase);
  }, [refills, tab]);

  const columns = useMemo(() => buildColumns(canAct), [canAct]);

  return (
    <div className="grid gap-5">
      <PageHeader
        title="Due Refills"
        description="Refills synced from dispensed medications, grouped by outreach phase."
        actions={
          <Button variant="outline" onClick={() => refetch()} disabled={isFetching}>
            <RefreshCw data-icon="inline-start" />
            Refresh
          </Button>
        }
      />

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <Card size="sm">
          <CardContent>
            <p className="text-xs leading-[16px] text-muted-foreground">Total active</p>
            <p className="text-[24px] leading-[30px] font-semibold text-title">{data?.total ?? "—"}</p>
          </CardContent>
        </Card>
        <Card size="sm">
          <CardContent>
            <p className="text-xs leading-[16px] text-muted-foreground">Outreach</p>
            <p className="text-[24px] leading-[30px] font-semibold text-title">{data?.outreach ?? "—"}</p>
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
            <p className="text-xs leading-[16px] text-muted-foreground">Overdue</p>
            <p className="text-[24px] leading-[30px] font-semibold text-danger">{data?.overdue ?? "—"}</p>
          </CardContent>
        </Card>
      </div>

      <PillTabs
        ariaLabel="Filter refills by phase"
        value={tab}
        onValueChange={(value) => setTab(value as PhaseFilter)}
        tabs={[
          { value: "all", label: `All (${data?.total ?? 0})` },
          { value: "outreach", label: `Outreach (${data?.outreach ?? 0})` },
          { value: "dueToday", label: `Due today (${data?.due_today ?? 0})` },
          { value: "overdue", label: `Overdue (${data?.overdue ?? 0})` },
        ]}
      >
        {(["all", "outreach", "dueToday", "overdue"] as const).map((value) => (
          <TabsContent key={value} value={value}>
            {tab === value && (
              <DataTable
                columns={columns}
                rows={filtered}
                rowKey={(r) => r.id}
                isLoading={isLoading}
                error={error}
                onRetry={() => refetch()}
                onRowClick={(r) => router.push(`/patients/${r.patient_id}/visits/${r.visit_id}`)}
                emptyTitle="No refills in this phase"
                emptyDescription="Refills appear here automatically once visits dispense medications with a refill date."
              />
            )}
          </TabsContent>
        ))}
      </PillTabs>
    </div>
  );
}
