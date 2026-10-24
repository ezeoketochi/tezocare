"use client";

import { usePathname, useRouter } from "next/navigation";
import { ChevronRight } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuLabel,
  DropdownMenuSeparator,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu";
import { SidebarTrigger } from "@/components/ui/sidebar";
import { useAuthActions, useSession } from "@/lib/features/auth/hooks";
import { roleLabel } from "@/lib/config/roles";
import { breadcrumbs } from "@/lib/config/nav";
import { NotificationBell } from "@/components/layout/notification-bell";

export function AppTopbar() {
  const pathname = usePathname();
  const router = useRouter();
  const { staff, pharmacy } = useSession();
  const { logout } = useAuthActions();

  const trail = breadcrumbs(pathname);

  return (
    <header className="sticky top-0 z-30 flex h-[55px] shrink-0 items-center gap-2 border-b border-line bg-surface px-3.5 md:px-6">
      <SidebarTrigger className="-ml-1 size-[30px] md:hidden" />
      <nav aria-label="Breadcrumb" className="flex min-w-0 items-center gap-1 text-sm leading-[22px]">
        {trail.map((label, i) => {
          const leaf = i === trail.length - 1;
          return (
            <span key={`${label}-${i}`} className="flex min-w-0 items-center gap-1">
              {i > 0 && <ChevronRight className="size-3.5 shrink-0 text-faint" aria-hidden />}
              <span className={leaf ? "truncate text-value" : "truncate text-faint"}>{label}</span>
            </span>
          );
        })}
      </nav>

      <div className="ml-auto flex shrink-0 items-center gap-2">
        <NotificationBell />
        <DropdownMenu>
          <DropdownMenuTrigger
            render={
              <Button
                variant="ghost"
                size="icon"
                className="size-[35px] rounded-nav border border-line"
                aria-label="Account menu"
              />
            }
          >
            <span className="flex size-[27px] items-center justify-center rounded-full bg-gold text-[12px] font-semibold text-ink">
              {(staff?.name ?? "?").slice(0, 1).toUpperCase()}
            </span>
          </DropdownMenuTrigger>
          <DropdownMenuContent align="end" className="w-60">
            <DropdownMenuLabel className="font-normal">
              <div className="grid gap-1">
                <span className="text-sm font-medium text-title">{staff?.name}</span>
                <span className="truncate text-xs text-muted-foreground">{staff?.email}</span>
                <div className="flex gap-1 pt-1">
                  {staff && <Badge>{roleLabel(staff.role)}</Badge>}
                  {pharmacy?.name && <Badge variant="outline">{pharmacy.name}</Badge>}
                </div>
              </div>
            </DropdownMenuLabel>
            <DropdownMenuSeparator />
            <DropdownMenuItem onClick={() => router.push("/settings?tab=account")}>Account</DropdownMenuItem>
            <DropdownMenuItem onClick={() => router.push("/settings?tab=security")}>Change password</DropdownMenuItem>
            <DropdownMenuSeparator />
            <DropdownMenuItem variant="destructive" onClick={() => logout()}>
              Log out
            </DropdownMenuItem>
          </DropdownMenuContent>
        </DropdownMenu>
      </div>
    </header>
  );
}
