"use client";

import { AlertCircle } from "lucide-react";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { can, type RoleAction } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";

export function RoleGate({ action, children }: { action: RoleAction; children: React.ReactNode }) {
  const { staff } = useSession();
  if (!can(staff?.role, action)) {
    return (
      <Alert variant="destructive">
        <AlertCircle className="size-4" />
        <AlertTitle>Not available</AlertTitle>
        <AlertDescription>Your role does not allow you to perform this action.</AlertDescription>
      </Alert>
    );
  }
  return <>{children}</>;
}
