"use client";

import { useEffect } from "react";
import { useRouter, useSearchParams } from "next/navigation";
import { Skeleton } from "@/components/ui/skeleton";
import { useSession } from "@/lib/features/auth/hooks";

export function AuthGuard({ children }: { children: React.ReactNode }) {
  const { status } = useSession();
  const router = useRouter();
  const searchParams = useSearchParams();

  useEffect(() => {
    if (status === "unauthenticated") {
      const next = searchParams.get("next");
      router.replace(`/login${next ? `?next=${encodeURIComponent(next)}` : ""}`);
    }
  }, [status, router, searchParams]);

  // Never return null here: a client guard that renders nothing drops its children from
  // the render tree, which breaks Cache Components' instant-navigation validation and shows
  // a blank screen while the redirect to /login is in flight.
  if (status !== "authenticated") return <AuthShell />;

  return <>{children}</>;
}

function AuthShell() {
  return (
    <div className="flex min-h-svh flex-col gap-4 p-6">
      <Skeleton className="h-10 w-40" />
      <div className="grid gap-4 md:grid-cols-3">
        <Skeleton className="h-28" />
        <Skeleton className="h-28" />
        <Skeleton className="h-28" />
      </div>
      <Skeleton className="h-64" />
    </div>
  );
}
