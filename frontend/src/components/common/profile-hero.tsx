"use client";

import { cn } from "cn";

/** Cover strip + overlapping avatar, from the Figma account header. */
export function ProfileHero({
  name,
  initials,
  subtitle,
  tag,
  actions,
  image,
  className,
}: {
  name: string;
  initials?: string;
  subtitle?: string;
  tag?: string;
  actions?: React.ReactNode;
  image?: React.ReactNode;
  className?: string;
}) {
  return (
    <div className={cn("overflow-hidden rounded-card border border-line bg-panel", className)}>
      <div className="side-nav-tint relative h-[130px] w-full opacity-25">{image}</div>
      <div className="flex flex-wrap items-end justify-between gap-3 px-4 pb-4">
        <div className="-mt-[36px] flex min-w-0 items-end gap-3.5">
          <span className="flex size-[85px] shrink-0 items-center justify-center rounded-full border-4 border-panel bg-line text-[30px] font-semibold text-title">
            {initials ?? name.slice(0, 1).toUpperCase()}
          </span>
          <div className="min-w-0 pb-1">
            <div className="flex min-w-0 items-center gap-2">
              <h2 className="truncate font-heading text-[24px] leading-[30px] font-semibold text-title">
                {name}
              </h2>
              {tag && (
                <span className="shrink-0 rounded-full bg-gold px-2.5 py-0.5 text-xs leading-[16px] text-ink">
                  {tag}
                </span>
              )}
            </div>
            {subtitle && (
              <p className="truncate text-[13px] leading-[20px] font-light text-muted-foreground">
                {subtitle}
              </p>
            )}
          </div>
        </div>
        {actions && <div className="flex shrink-0 items-center gap-2 self-center">{actions}</div>}
      </div>
    </div>
  );
}
