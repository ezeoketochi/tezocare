"use client";

import { useRouter } from "next/navigation";
import { useState } from "react";
import { Pencil, Plus, UserMinus } from "lucide-react";
import { PageHeader } from "@/components/common/page-header";
import { ConfirmDialog } from "@/components/common/confirm-dialog";
import { DataTable, type DataTableColumn } from "@/components/common/data-table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { RoleGuard } from "@/components/guards/role-guard";
import { useSession } from "@/lib/features/auth/hooks";
import { useDeactivateStaff, useStaffList } from "@/lib/features/staff/hooks";
import type { Staff } from "@/lib/api/types";
import { roleLabel } from "@/lib/config/roles";
import { formatDate } from "@/lib/utils/format";

const PAGE_SIZE = 20;

function StaffListContent() {
  const router = useRouter();
  const { staff: me } = useSession();
  const [page, setPage] = useState(1);
  const [confirmId, setConfirmId] = useState<string | null>(null);
  const query = useStaffList({ skip: (page - 1) * PAGE_SIZE, limit: PAGE_SIZE });
  const deactivate = useDeactivateStaff();

  const rows = query.data?.items ?? [];
  const hasNext = rows.length === PAGE_SIZE;

  const columns: DataTableColumn<Staff>[] = [
    {
      header: "Name",
      cell: (s) => (
        <div>
          <div className="font-medium">
            {s.name}
            {s.id === me?.id && <span className="ml-1 text-xs text-muted-foreground">(you)</span>}
          </div>
          <div className="text-xs text-muted-foreground">{s.email}</div>
        </div>
      ),
    },
    { header: "Role", cell: (s) => <Badge variant="secondary">{roleLabel(s.role)}</Badge> },
    {
      header: "Status",
      cell: (s) => (s.is_active ? <Badge variant="outline">Active</Badge> : <Badge variant="destructive">Inactive</Badge>),
    },
    { header: "Added", cell: (s) => formatDate(s.created_at) },
    {
      header: "Actions",
      className: "text-right",
      cell: (s) => (
        <div className="flex flex-wrap items-center justify-end gap-1" onClick={(e) => e.stopPropagation()}>
          <Button
            type="button"
            size="icon-sm"
            variant="ghost"
            aria-label={`Edit ${s.name}`}
            onClick={() => router.push(`/settings/staff/${s.id}`)}
          >
            <Pencil />
          </Button>
          {s.is_active && s.id !== me?.id && (
            <Button
              type="button"
              size="icon-sm"
              variant="ghost"
              aria-label={`Deactivate ${s.name}`}
              onClick={() => setConfirmId(s.id)}
            >
              <UserMinus />
            </Button>
          )}
        </div>
      ),
    },
  ];

  const confirming = rows.find((s) => s.id === confirmId);

  return (
    <div className="grid gap-5">
      <PageHeader
        title="Staff"
        description="People who can sign in to this pharmacy."
        actions={
          <Button onClick={() => router.push("/settings/staff/new")}>
            <Plus data-icon="inline-start" />
            Add staff
          </Button>
        }
      />

      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(s) => s.id}
        onRowClick={(s) => router.push(`/settings/staff/${s.id}`)}
        isLoading={query.isPending}
        error={query.error}
        onRetry={() => query.refetch()}
        emptyTitle="No staff found"
        emptyDescription="Add pharmacists and data entry staff so they can sign in."
      />

      <div className="flex items-center justify-end gap-2">
        <Button variant="outline" size="sm" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
          Previous
        </Button>
        <span className="text-sm text-muted-foreground">Page {page}</span>
        <Button variant="outline" size="sm" disabled={!hasNext} onClick={() => setPage((p) => p + 1)}>
          Next
        </Button>
      </div>

      <ConfirmDialog
        open={confirmId !== null}
        onOpenChange={(open) => !open && setConfirmId(null)}
        title={`Deactivate ${confirming?.name ?? "this staff member"}?`}
        description="They will no longer be able to sign in. You can re-activate them later from their profile."
        confirmLabel="Deactivate"
        destructive
        pending={deactivate.isPending}
        onConfirm={() => (confirmId ? deactivate.mutateAsync(confirmId) : Promise.resolve())}
      />
    </div>
  );
}

export default function StaffPage() {
  return (
    <RoleGuard minRole="admin">
      <StaffListContent />
    </RoleGuard>
  );
}
