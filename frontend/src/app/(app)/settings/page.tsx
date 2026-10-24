"use client";

import { Suspense } from "react";
import Link from "next/link";
import { useRouter, useSearchParams } from "next/navigation";
import { AlertCircle, Bell, Building2, ShieldCheck, UserRound, Users } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { PillTabs } from "@/components/common/pill-tabs";
import { SettingsAccount } from "@/components/settings/settings-account";
import { SettingsSecurity } from "@/components/settings/settings-security";
import { PharmacyForm } from "@/components/settings/pharmacy-form";
import { NotificationFeed } from "@/components/notifications/notification-feed";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { Card, CardContent } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { TabsContent } from "@/components/ui/tabs";
import { hasRole } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";
import { useMyPharmacy } from "@/lib/features/pharmacy/hooks";

function PharmacyTab() {
  const { pharmacy: sessionPharmacy } = useSession();
  const hasPharmacy = Boolean(sessionPharmacy?.id);
  const { data, isPending, error, refetch } = useMyPharmacy(hasPharmacy);

  if (isPending && hasPharmacy) {
    return (
      <Card>
        <CardContent>
          <div className="grid gap-4 sm:grid-cols-3">
            {Array.from({ length: 4 }).map((_, i) => (
              <Skeleton key={i} className="h-[45px] w-full" />
            ))}
          </div>
        </CardContent>
      </Card>
    );
  }

  if (!hasPharmacy || error || !data) {
    return (
      <Alert>
        <AlertCircle />
        <AlertTitle>No pharmacy linked</AlertTitle>
        <AlertDescription>
          This account isn&apos;t attached to a pharmacy, so there&apos;s nothing to edit here.
          <span className="mt-2 block">
            <Button size="sm" variant="outline" onClick={() => refetch()}>
              Retry
            </Button>
          </span>
        </AlertDescription>
      </Alert>
    );
  }

  return (
    <Card>
      <CardContent>
        <PharmacyForm key={data.id} pharmacy={data} />
      </CardContent>
    </Card>
  );
}

function SettingsContent() {
  const router = useRouter();
  const searchParams = useSearchParams();
  const { staff } = useSession();

  const tabs = [
    { value: "account", label: "Account", icon: UserRound },
    { value: "security", label: "Security", icon: ShieldCheck },
    { value: "notifications", label: "Notifications", icon: Bell },
    ...(hasRole(staff?.role, "admin")
      ? [
          { value: "pharmacy", label: "Pharmacy", icon: Building2 },
          { value: "team", label: "Team", icon: Users },
        ]
      : []),
  ];

  const requested = searchParams.get("tab");
  const tab = tabs.some((item) => item.value === requested) ? requested! : "account";

  function select(value: string) {
    router.push(value === "account" ? "/settings" : `/settings?tab=${value}`);
  }

  return (
    <>
      <PageHeader title="Settings" description="Your account, security and pharmacy configuration." />

      <PillTabs tabs={tabs} value={tab} onValueChange={select} ariaLabel="Settings sections">
        {tab === "account" && (
          <TabsContent value="account">
            <SettingsAccount />
          </TabsContent>
        )}
        {tab === "security" && (
          <TabsContent value="security">
            <SettingsSecurity />
          </TabsContent>
        )}
        {tab === "notifications" && (
          <TabsContent value="notifications">
            <NotificationFeed />
          </TabsContent>
        )}
        {tab === "pharmacy" && (
          <TabsContent value="pharmacy">
            <PharmacyTab />
          </TabsContent>
        )}
        {tab === "team" && (
          <TabsContent value="team">
            <Card>
              <CardContent>
                <div className="flex flex-wrap items-center justify-between gap-3">
                  <div className="min-w-0">
                    <p className="text-[15px] leading-[22px] text-title">Pharmacy team</p>
                    <p className="mt-1 text-[13px] leading-[20px] font-light text-muted-foreground">
                      Add, edit or deactivate the staff who sign in to this pharmacy.
                    </p>
                  </div>
                  <Button render={<Link href="/settings/staff" />}>
                    <Users data-icon="inline-start" />
                    Manage staff
                  </Button>
                </div>
              </CardContent>
            </Card>
          </TabsContent>
        )}
      </PillTabs>
    </>
  );
}

export default function SettingsPage() {
  return (
    <Suspense fallback={<Skeleton className="h-64 w-full" />}>
      <SettingsContent />
    </Suspense>
  );
}
