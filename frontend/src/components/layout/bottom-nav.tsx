"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { isActiveNav, MOBILE_NAV } from "@/lib/config/nav";

export function BottomNav() {
  const pathname = usePathname();
  return (
    <nav
      aria-label="Primary"
      className="fixed inset-x-0 bottom-0 z-40 flex h-16 items-stretch border-t border-line bg-ink pb-[env(safe-area-inset-bottom)] md:hidden"
    >
      {MOBILE_NAV.map((item) => {
        const active = isActiveNav(item, pathname);
        return (
          <Link
            key={item.href}
            href={item.href}
            aria-current={active ? "page" : undefined}
            className={`flex flex-1 flex-col items-center justify-center gap-1 text-[11px] leading-[16px] transition-colors ${
              active ? "text-gold" : "text-muted-foreground hover:text-foreground"
            }`}
          >
            <item.icon className="size-5" />
            {item.title}
          </Link>
        );
      })}
    </nav>
  );
}
