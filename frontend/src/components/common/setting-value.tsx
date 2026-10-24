"use client";

import { Pencil } from "lucide-react";
import { cn } from "cn";

/** Label-over-value row used across the settings tabs and detail screens. */
export function SettingValue({
  label,
  value,
  children,
  onEdit,
  editLabel,
  className,
}: {
  label: string;
  value?: React.ReactNode;
  children?: React.ReactNode;
  onEdit?: () => void;
  editLabel?: string;
  className?: string;
}) {
  const body = (
    <span className="mt-1 flex min-w-0 items-center gap-1.5 text-[15px] leading-[22px] text-title">
      <span className="min-w-0 truncate">{children ?? value ?? "—"}</span>
      {onEdit && <Pencil className="size-3.5 shrink-0 text-muted-foreground group-hover/edit:text-gold" />}
    </span>
  );

  return (
    <div className={cn("min-w-0", className)}>
      <p className="text-sm leading-[22px] font-light text-muted-foreground">{label}</p>
      {onEdit ? (
        <button
          type="button"
          onClick={onEdit}
          className="group/edit -mx-1 block w-full max-w-full rounded-btn px-1 text-left hover:bg-panel focus-visible:outline-1 focus-visible:outline-ring"
          aria-label={editLabel ? `${editLabel}: ${label}` : `Edit ${label}`}
        >
          {body}
        </button>
      ) : (
        body
      )}
    </div>
  );
}
