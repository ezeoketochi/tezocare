"use client";

import { notFound } from "next/navigation";
import { hasRole } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";
import type { StaffRole } from "@/lib/api/types";

export function RoleGuard({ minRole, children }: { minRole: StaffRole; children: React.ReactNode }) {
  const { staff } = useSession();
  if (!hasRole(staff?.role, minRole)) {
    notFound();
  }
  return <>{children}</>;
}
