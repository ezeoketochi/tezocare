"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { HeartPulse, LogOut } from "lucide-react";
import { Sidebar, SidebarContent, SidebarHeader } from "@/components/ui/sidebar";
import { PRIMARY_NAV, isActiveNav, sectionCta } from "@/lib/config/nav";
import { hasRole } from "@/lib/config/roles";
import { useAuthActions, useSession } from "@/lib/features/auth/hooks";

export function AppSidebar() {
  const pathname = usePathname();
  const { staff, pharmacy } = useSession();
  const { logout } = useAuthActions();

  const items = PRIMARY_NAV.filter(
    (item) => !item.minRole || hasRole(staff?.role, item.minRole)
  );
  const cta = sectionCta(pathname, staff?.role);

  return (
    <Sidebar
      collapsible="none"
      className="border-r-0"
      aria-label="Primary navigation"
    >
      <div className="side-nav-tint flex h-full min-h-0 w-full flex-col text-ink">
        <SidebarHeader className="px-3.5 pt-5 pb-4">
          <Link href="/dashboard" className="flex items-center gap-2.5">
            <span className="flex size-[45px] shrink-0 items-center justify-center rounded-nav bg-ink text-gold">
              <HeartPulse className="size-6" />
            </span>
            <span className="grid min-w-0 text-left leading-tight">
              <span className="font-heading truncate text-[15px] font-semibold text-ink">TezoCare</span>
              <span className="truncate text-[12px] leading-[16px] text-ink/60">
                {pharmacy?.name ?? "Workspace"}
              </span>
            </span>
          </Link>
        </SidebarHeader>

        <SidebarContent className="min-h-0 gap-0 px-3.5">
          <nav className="flex flex-col gap-2">
            {items.map((item) => {
              const active = isActiveNav(item, pathname);
              return (
                <Link
                  key={item.href}
                  href={item.href}
                  aria-current={active ? "page" : undefined}
                  className={`flex h-[38px] items-center gap-2.5 rounded-nav px-2.5 text-sm leading-[22px] transition-colors ${
                    active
                      ? "bg-ink/12 font-medium text-ink"
                      : "text-ink opacity-80 hover:opacity-100"
                  }`}
                >
                  <item.icon className="size-3.5 shrink-0" />
                  <span className="truncate">{item.title}</span>
                </Link>
              );
            })}
            <button
              type="button"
              onClick={() => logout()}
              className="flex h-[38px] items-center gap-2.5 rounded-nav px-2.5 text-left text-sm leading-[22px] text-danger opacity-90 transition-opacity hover:opacity-100"
            >
              <LogOut className="size-3.5 shrink-0" />
              <span>Log out</span>
            </button>
          </nav>

          <div className="mt-auto border-t border-gold-deep/30 pt-4">
            <div className="rounded-nav border-2 border-gold-deep/30 bg-ink/8 p-3">
              <p className="text-[13px] leading-[20px] font-light text-ink/70">{cta.caption}</p>
              <Link
                href={cta.href}
                className="mt-3 flex h-[38px] items-center justify-center gap-1.5 rounded-btn bg-ink text-[13px] font-medium leading-[20px] text-gold transition-colors hover:bg-[#1a1a22]"
              >
                <cta.icon className="size-3.5" />
                {cta.label}
              </Link>
            </div>
            <p className="px-1 pt-3 text-[11px] leading-[16px] text-ink/50">{staff?.email}</p>
          </div>
        </SidebarContent>
      </div>
    </Sidebar>
  );
}
