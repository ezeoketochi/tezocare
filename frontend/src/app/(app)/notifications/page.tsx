"use client";

import { AlertCircle, RefreshCw } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { NotificationFeed } from "@/components/notifications/notification-feed";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { Button } from "@/components/ui/button";
import { getErrorMessage } from "@/lib/api/errors";
import { useNotifications } from "@/lib/features/notifications/hooks";

export default function NotificationsPage() {
  const { error, refetch, isFetching } = useNotifications();

  return (
    <>
      <PageHeader
        title="Notifications"
        description="Refill and follow-up reminders for your patients."
        actions={
          <Button variant="outline" onClick={() => refetch()} disabled={isFetching}>
            <RefreshCw data-icon="inline-start" />
            Refresh
          </Button>
        }
      />

      {error ? (
        <Alert variant="destructive">
          <AlertCircle />
          <AlertTitle>Could not load notifications</AlertTitle>
          <AlertDescription className="flex flex-wrap items-center justify-between gap-2">
            <span>{getErrorMessage(error)}</span>
            <Button size="sm" variant="outline" onClick={() => refetch()}>
              Retry
            </Button>
          </AlertDescription>
        </Alert>
      ) : (
        <NotificationFeed />
      )}
    </>
  );
}
