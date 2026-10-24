"use client";

import { useRouter } from "next/navigation";
import { Bell } from "lucide-react";
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
import { useMarkNotificationRead, useNotifications } from "@/lib/features/notifications/hooks";
import type { StaffNotification } from "@/lib/features/notifications/types";
import { timeAgo } from "@/lib/utils/format";

export function NotificationBell() {
  const router = useRouter();
  const { data } = useNotifications();
  const markRead = useMarkNotificationRead();

  const unread = data?.unread_count ?? 0;
  const recent: StaffNotification[] = (data?.notifications ?? []).slice(0, 5);

  function open(n: StaffNotification) {
    if (n.status !== "read") markRead.mutate(n.id);
    if (n.patient_id) router.push(`/patients/${n.patient_id}`);
    else router.push("/notifications");
  }

  return (
    <DropdownMenu>
      <DropdownMenuTrigger
        render={
          <Button
            variant="ghost"
            size="icon"
            className="h-[35px] w-[38px] rounded-nav"
            aria-label={`Notifications${unread ? ` (${unread} unread)` : ""}`}
          />
        }
      >
        <span className="relative">
          <Bell />
          {unread > 0 && (
            <Badge className="absolute -top-2 -right-1.5 h-[16px] min-w-[16px] border-0 bg-danger px-1 text-[10px] leading-none text-white font-medium">
              {unread > 9 ? "9+" : unread}
            </Badge>
          )}
        </span>
      </DropdownMenuTrigger>
      <DropdownMenuContent align="end" className="w-80">
        <DropdownMenuLabel className="flex items-center justify-between text-sm">
          <span>Notifications</span>
          {unread > 0 && <span className="text-xs font-normal text-muted-foreground">{unread} unread</span>}
        </DropdownMenuLabel>
        <DropdownMenuSeparator />
        {recent.length === 0 ? (
          <div className="px-2 py-6 text-center text-sm text-muted-foreground">No notifications yet.</div>
        ) : (
          recent.map((n) => (
            <DropdownMenuItem key={n.id} onClick={() => open(n)} className="flex flex-col items-start gap-0.5 py-2">
              <span className="flex w-full items-center gap-2">
                {n.status !== "read" && <span className="size-2 shrink-0 rounded-full bg-primary" aria-hidden />}
                <span className={`truncate text-sm ${n.status !== "read" ? "font-semibold" : "font-medium"}`}>{n.title}</span>
              </span>
              <span className="line-clamp-2 w-full text-xs text-muted-foreground">{n.message}</span>
              <span className="text-[10px] text-muted-foreground">{timeAgo(n.created_at)}</span>
            </DropdownMenuItem>
          ))
        )}
        <DropdownMenuSeparator />
        <DropdownMenuItem onClick={() => router.push("/notifications")} className="justify-center text-sm font-medium">
          View all notifications
        </DropdownMenuItem>
      </DropdownMenuContent>
    </DropdownMenu>
  );
}
