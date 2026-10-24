"use client";

import { useState } from "react";
import {
  AlertDialog,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
  AlertDialogTrigger,
} from "@/components/ui/alert-dialog";
import { Button } from "@/components/ui/button";
import { cn } from "cn";

/** Figma confirmation modal: ghost Cancel beside a solid Confirm. */
export function ConfirmDialog({
  open,
  onOpenChange,
  title,
  description,
  confirmLabel = "Confirm",
  cancelLabel = "Cancel",
  onConfirm,
  pending,
  destructive,
  trigger,
}: {
  open?: boolean;
  onOpenChange?: (open: boolean) => void;
  title: string;
  description?: React.ReactNode;
  confirmLabel?: string;
  cancelLabel?: string;
  onConfirm: () => void | Promise<unknown>;
  pending?: boolean;
  destructive?: boolean;
  trigger?: React.ReactElement;
}) {
  const [busy, setBusy] = useState(false);

  async function confirm() {
    setBusy(true);
    try {
      await onConfirm();
      onOpenChange?.(false);
    } catch {
      // Failure reporting belongs to the caller (or the global error toast);
      // leaving the dialog open lets the user retry.
    } finally {
      setBusy(false);
    }
  }

  const working = busy || Boolean(pending);

  return (
    <AlertDialog open={open} onOpenChange={onOpenChange}>
      {trigger && <AlertDialogTrigger render={trigger} />}
      <AlertDialogContent>
        <AlertDialogHeader>
          <AlertDialogTitle className="text-[20px] leading-[26px] font-semibold text-title">
            {title}
          </AlertDialogTitle>
          {description && <AlertDialogDescription>{description}</AlertDialogDescription>}
        </AlertDialogHeader>
        <AlertDialogFooter>
          <AlertDialogCancel disabled={working}>{cancelLabel}</AlertDialogCancel>
          <Button
            variant={destructive ? "destructive" : "default"}
            disabled={working}
            onClick={confirm}
            className={cn(working && "opacity-70")}
          >
            {working ? "Working…" : confirmLabel}
          </Button>
        </AlertDialogFooter>
      </AlertDialogContent>
    </AlertDialog>
  );
}
