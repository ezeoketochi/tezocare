"use client";

import type { LucideIcon } from "lucide-react";
import { cn } from "cn";

/**
 * Figma settings row: a 24px gold icon chip beside the section label, a hairline
 * divider, then the values. Stack several inside one Card to rebuild a page.
 */
export function SettingsSection({
  icon: Icon,
  title,
  action,
  children,
  className,
  divider = true,
}: {
  icon?: LucideIcon;
  title: string;
  action?: React.ReactNode;
  children?: React.ReactNode;
  className?: string;
  divider?: boolean;
}) {
  return (
    <section
      className={cn(
        "py-5 first:pt-0 last:pb-0",
        divider && "border-b border-line last:border-b-0",
        className
      )}
    >
      <header className="flex items-center gap-3">
        {Icon && (
          <span className="flex size-6 shrink-0 items-center justify-center rounded-full bg-gold text-ink">
            <Icon className="size-3.5" />
          </span>
        )}
        <h2 className="min-w-0 flex-1 truncate text-base leading-[22px] font-normal text-label">
          {title}
        </h2>
        {action && <div className="flex shrink-0 items-center gap-2">{action}</div>}
      </header>
      {children && <div className="mt-4">{children}</div>}
    </section>
  );
}
