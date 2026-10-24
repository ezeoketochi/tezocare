"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { Bell } from "lucide-react";
import { PillTabs } from "@/components/common/pill-tabs";
import { TabsContent } from "@/components/ui/tabs";
import { Card } from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { useMarkNotificationRead, useNotifications } from "@/lib/features/notifications/hooks";
import type { StaffNotification } from "@/lib/features/notifications/types";
import { timeAgo } from "@/lib/utils/format";

function NotificationRow({
  notification,
  onOpen,
}: {
  notification: StaffNotification;
  onOpen: (notification: StaffNotification) => void;
}) {
  const unread = notification.status !== "read";
  return (
    <button
      type="button"
      onClick={() => onOpen(notification)}
      className="flex w-full items-start gap-3.5 border-b border-line px-6 py-4 text-left transition-colors last:border-b-0 hover:bg-ink/40"
    >
      <span
        className={`mt-0.5 flex size-6 shrink-0 items-center justify-center rounded-full ${
          unread ? "bg-gold text-ink" : "bg-line text-muted-foreground"
        }`}
      >
        <Bell className="size-3.5" />
      </span>
      <span className="min-w-0 flex-1">
        <span className="block truncate text-[15px] leading-[22px] text-title">{notification.title}</span>
        <span className="mt-1 block text-[13px] leading-[20px] font-light text-muted-foreground">
          {notification.message}
        </span>
        <span className="mt-1 block text-xs leading-[16px] text-faint">
          {timeAgo(notification.created_at)}
          {notification.patient_name ? ` · ${notification.patient_name}` : ""}
        </span>
      </span>
      {unread && <span className="mt-2 size-2 shrink-0 rounded-full bg-gold" aria-label="Unread" />}
    </button>
  );
}

export function NotificationFeed() {
  const router = useRouter();
  const { data, isPending } = useNotifications();
  const markRead = useMarkNotificationRead();
  const [tab, setTab] = useState("all");

  const notifications = data?.notifications ?? [];
  const unreadCount = data?.unread_count ?? 0;
  const tabs = [
    { value: "all", label: "All" },
    { value: "unread", label: `Unread (${unreadCount})` },
  ];

  function open(notification: StaffNotification) {
    if (notification.status !== "read") markRead.mutate(notification.id);
    if (notification.patient_id) router.push(`/patients/${notification.patient_id}`);
  }

  return (
    <PillTabs tabs={tabs} value={tab} onValueChange={setTab} ariaLabel="Notification filters">
      {tabs.map(({ value }) => {
        const shown = value === "all" ? notifications : notifications.filter((n) => n.status !== "read");
        return (
          <TabsContent key={value} value={value}>
            {tab === value &&
              (isPending ? (
                <Card className="gap-0 py-0">
                  {Array.from({ length: 4 }).map((_, i) => (
                    <div key={i} className="border-b border-line px-6 py-4 last:border-b-0">
                      <Skeleton className="h-4 w-40" />
                      <Skeleton className="mt-2 h-3 w-64" />
                    </div>
                  ))}
                </Card>
              ) : shown.length === 0 ? (
                <div className="flex flex-col items-center justify-center gap-2 rounded-card border border-dashed border-line py-14 text-center">
                  <Bell className="size-8 text-muted-foreground" />
                  <p className="text-[15px] text-title">{value === "all" ? "No notifications" : "Nothing unread"}</p>
                  <p className="max-w-sm text-[13px] leading-[20px] font-light text-muted-foreground">
                    Refill and follow-up reminders for your patients will appear here.
                  </p>
                </div>
              ) : (
                <Card className="gap-0 py-0">
                  {shown.map((n) => (
                    <NotificationRow key={n.id} notification={n} onOpen={open} />
                  ))}
                </Card>
              ))}
          </TabsContent>
        );
      })}
    </PillTabs>
  );
}
