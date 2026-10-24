"use client";

import { Building2, UserRound } from "lucide-react";
import { Card, CardContent } from "@/components/ui/card";
import { ProfileHero } from "@/components/common/profile-hero";
import { SettingsSection } from "@/components/common/settings-section";
import { SettingValue } from "@/components/common/setting-value";
import { roleLabel } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";

export function SettingsAccount() {
  const { staff, pharmacy } = useSession();

  return (
    <div className="grid gap-5">
      <ProfileHero
        name={staff?.name ?? "—"}
        subtitle={staff?.email}
        tag={staff ? roleLabel(staff.role) : undefined}
      />

      <Card>
        <CardContent>
          <SettingsSection icon={UserRound} title="Account details">
            <div className="grid gap-5 sm:grid-cols-3">
              <SettingValue label="Full name" value={staff?.name ?? "—"} />
              <SettingValue label="Email" value={staff?.email ?? "—"} />
              <SettingValue label="Role" value={staff ? roleLabel(staff.role) : "—"} />
            </div>
          </SettingsSection>

          <SettingsSection icon={Building2} title="Pharmacy" divider={false}>
            <div className="grid gap-5 sm:grid-cols-3">
              <SettingValue label="Name" value={pharmacy?.name ?? "Not linked"} />
            </div>
          </SettingsSection>
        </CardContent>
      </Card>
    </div>
  );
}
