"use client";

import { useRouter } from "next/navigation";
import { AlertCircle, ArrowRight, Users } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardAction, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { can } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";
import { useDashboardSummary } from "@/lib/features/dashboard/hooks";
import type { DashboardRefillItem } from "@/lib/features/dashboard/types";
import { formatDate } from "@/lib/utils/format";

const VISIT_STATUS_VARIANT: Record<string, "default" | "secondary" | "outline" | "destructive"> = {
  active: "default",
  completed: "secondary",
  follow_up_pending: "outline",
  referred: "destructive",
};

function StatCard({ label, value, loading }: { label: string; value: number | undefined; loading: boolean }) {
  return (
    <Card size="sm">
      <CardContent>
        <p className="text-xs leading-[16px] text-muted-foreground">{label}</p>
        {loading ? (
          <Skeleton className="mt-1 h-[30px] w-16" />
        ) : (
          <p className="text-[24px] leading-[30px] font-semibold text-title">{value ?? 0}</p>
        )}
      </CardContent>
    </Card>
  );
}

export default function DashboardPage() {
  const router = useRouter();
  const { staff } = useSession();
  const allowed = can(staff?.role, "dashboardView");
  const { data, isPending, error, refetch } = useDashboardSummary(allowed);

  if (!allowed) {
    return (
      <div className="grid gap-5">
        <PageHeader title="Dashboard" description="Your pharmacy at a glance." />
        <Alert>
          <AlertCircle />
          <AlertTitle>Dashboard not available</AlertTitle>
          <AlertDescription>
            Your role doesn&apos;t have access to the dashboard. Head to{" "}
            <Button variant="link" className="h-auto p-0" onClick={() => router.push("/patients")}>
              Patients
            </Button>{" "}
            to get started.
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  if (error) {
    return (
      <div>
        <PageHeader title="Dashboard" description="Your pharmacy at a glance." />
        <Alert variant="destructive">
          <AlertCircle />
          <AlertTitle>Could not load dashboard</AlertTitle>
          <AlertDescription className="flex flex-wrap items-center justify-between gap-2">
            <span>{error.message}</span>
            <Button size="sm" variant="outline" onClick={() => refetch()}>
              Retry
            </Button>
          </AlertDescription>
        </Alert>
      </div>
    );
  }

  const refillsDueSoon = data?.refills_due_soon ?? [];
  const upcomingRefills = data?.upcoming_refills ?? [];
  const recentVisits = data?.recent_patients ?? [];

  return (
    <div className="grid gap-5">
      <PageHeader
        title="Dashboard"
        description={`Welcome back${staff?.name ? `, ${staff.name.split(" ")[0]}` : ""}.`}
      />

      <div className="grid grid-cols-2 gap-3 lg:grid-cols-4">
        <StatCard label="Total patients" value={data?.total_patients} loading={isPending} />
        <StatCard label="Visits today" value={data?.visits_today} loading={isPending} />
        <StatCard label="Follow-ups pending" value={data?.follow_ups_pending} loading={isPending} />
        <StatCard label="Refills due (3 days)" value={refillsDueSoon.length} loading={isPending} />
      </div>

      <div className="grid gap-5 lg:grid-cols-2">
        <Card>
          <CardHeader>
            <CardTitle className="text-base">Refills due soon</CardTitle>
            <CardAction>
              <Button variant="ghost" size="xs" onClick={() => router.push("/refills")}>
                View all
                <ArrowRight data-icon="inline-end" />
              </Button>
            </CardAction>
          </CardHeader>
          <CardContent>
            {isPending ? (
              <div className="space-y-2">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-10 w-full" />
                ))}
              </div>
            ) : refillsDueSoon.length === 0 ? (
              <p className="py-4 text-sm text-muted-foreground">No refills due in the next 3 days.</p>
            ) : (
              <ul className="divide-line divide-y">
                {refillsDueSoon.slice(0, 6).map((r: DashboardRefillItem, i) => (
                  <li key={`${r.visit_id}-${r.drug_name}-${i}`} className="flex items-center justify-between gap-2 py-2 text-sm">
                    <button
                      type="button"
                      className="min-w-0 text-left"
                      onClick={() => router.push(`/patients/${r.patient_id}/visits/${r.visit_id}`)}
                    >
                      <span className="block truncate text-[15px] leading-[22px] text-title">{r.drug_name}</span>
                      <span className="block truncate text-xs leading-[16px] text-muted-foreground">
                        {r.dose} · refill {formatDate(r.refill_date)}
                      </span>
                    </button>
                    <Button variant="ghost" size="icon-sm" aria-label="Open patient" onClick={() => router.push(`/patients/${r.patient_id}`)}>
                      <Users />
                    </Button>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle className="text-base">Upcoming refills</CardTitle>
          </CardHeader>
          <CardContent>
            {isPending ? (
              <div className="space-y-2">
                {Array.from({ length: 3 }).map((_, i) => (
                  <Skeleton key={i} className="h-10 w-full" />
                ))}
              </div>
            ) : upcomingRefills.length === 0 ? (
              <p className="py-4 text-sm text-muted-foreground">Nothing scheduled yet.</p>
            ) : (
              <ul className="divide-line divide-y">
                {upcomingRefills.map((r, i) => (
                  <li key={`${r.visit_id}-${r.drug_name}-${i}`} className="py-2 text-sm">
                    <button
                      type="button"
                      className="min-w-0 text-left"
                      onClick={() => router.push(`/patients/${r.patient_id}/visits/${r.visit_id}`)}
                    >
                      <span className="block truncate text-[15px] leading-[22px] text-title">{r.drug_name}</span>
                      <span className="block truncate text-xs leading-[16px] text-muted-foreground">
                        {r.dose} · refill {formatDate(r.refill_date)}
                      </span>
                    </button>
                  </li>
                ))}
              </ul>
            )}
          </CardContent>
        </Card>
      </div>

      <Card>
        <CardHeader>
          <CardTitle className="text-base">Recent visits</CardTitle>
          <CardAction>
            <Button variant="ghost" size="xs" onClick={() => router.push("/patients")}>
              Patients
              <ArrowRight data-icon="inline-end" />
            </Button>
          </CardAction>
        </CardHeader>
        <CardContent>
          {isPending ? (
            <div className="space-y-2">
              {Array.from({ length: 3 }).map((_, i) => (
                <Skeleton key={i} className="h-10 w-full" />
              ))}
            </div>
          ) : recentVisits.length === 0 ? (
            <p className="py-4 text-sm text-muted-foreground">No visits recorded yet.</p>
          ) : (
            <ul className="divide-line divide-y">
              {recentVisits.map((v) => (
                <li key={v.visit_id} className="flex items-center justify-between gap-2 py-2 text-sm">
                  <button
                    type="button"
                    className="text-[15px] leading-[22px] text-title hover:underline"
                    onClick={() => router.push(`/patients/${v.patient_id}/visits/${v.visit_id}`)}
                  >
                    Visit {formatDate(v.visit_date)}
                  </button>
                  {v.status && <Badge variant={VISIT_STATUS_VARIANT[v.status] ?? "outline"}>{v.status}</Badge>}
                </li>
              ))}
            </ul>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
