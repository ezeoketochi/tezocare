"use client";

import { useEffect, useMemo, useState } from "react";
import Link from "next/link";
import { usePathname, useRouter, useSearchParams } from "next/navigation";
import { Plus } from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Input } from "@/components/ui/input";
import { DataTable, type DataTableColumn } from "@/components/common/data-table";
import { PageHeader } from "@/components/common/page-header";
import { useDebounce } from "@/lib/hooks/use-debounce";
import { usePatients } from "@/lib/features/patients/hooks";
import { ageFromDob, patientFullName, patientInitials, type Patient } from "@/lib/features/patients/types";
import { formatDate } from "@/lib/utils/format";
import { can } from "@/lib/config/roles";
import { useSession } from "@/lib/features/auth/hooks";

const PAGE_SIZE = 20;

export function PatientsList() {
  const router = useRouter();
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const { staff } = useSession();

  const [search, setSearch] = useState(searchParams.get("search") ?? "");
  const debouncedSearch = useDebounce(search, 300);
  const page = Math.max(1, Number(searchParams.get("page") ?? 1));

  const params = useMemo(
    () => ({ skip: (page - 1) * PAGE_SIZE, limit: PAGE_SIZE, search: debouncedSearch || undefined }),
    [page, debouncedSearch]
  );

  const query = usePatients(params);
  const rows = query.data?.items ?? [];
  const meta = query.data?.meta ?? null;

  // Keep the URL shareable: sync debounced search + page.
  useEffect(() => {
    const qs = new URLSearchParams();
    if (debouncedSearch) qs.set("search", debouncedSearch);
    if (page > 1) qs.set("page", String(page));
    router.replace(`${pathname}${qs.size ? `?${qs}` : ""}`, { scroll: false });
  }, [debouncedSearch, page, pathname, router]);

  const columns: DataTableColumn<Patient>[] = [
    {
      header: "Name",
      cell: (p) => (
        <div className="flex items-center gap-2">
          <span className="flex size-7 shrink-0 items-center justify-center rounded-full bg-gold text-xs font-semibold text-ink">
            {patientInitials(p)}
          </span>
          <span className="text-title">{patientFullName(p)}</span>
        </div>
      ),
    },
    { header: "Age", cell: (p) => (ageFromDob(p.date_of_birth) ?? "—") as React.ReactNode },
    { header: "Gender", cell: (p) => <Badge variant="outline">{p.gender}</Badge> },
    { header: "Phone", cell: (p) => p.phone ?? "—" },
    { header: "Registered", cell: (p) => formatDate(p.created_at) },
  ];

  return (
    <div className="grid gap-5">
      <PageHeader
        title="Patients"
        description="Everyone registered at your pharmacy."
        actions={
          can(staff?.role, "patientCreate") && (
            <Button render={<Link href="/patients/new" />}>
              <Plus data-icon="inline-start" /> New patient
            </Button>
          )
        }
      />
      <div className="max-w-sm">
        <Input
          value={search}
          onChange={(e) => {
            setSearch(e.target.value);
            if (page !== 1) router.replace(`${pathname}?search=${encodeURIComponent(e.target.value)}`, { scroll: false });
          }}
          placeholder="Search by name or phone…"
          aria-label="Search patients"
        />
      </div>

      <DataTable
        columns={columns}
        rows={rows}
        rowKey={(p) => p.id}
        onRowClick={(p) => router.push(`/patients/${p.id}`)}
        isLoading={query.isPending}
        error={query.error}
        onRetry={() => query.refetch()}
        emptyTitle={debouncedSearch ? "No matching patients" : "No patients yet"}
        emptyDescription={
          debouncedSearch ? "Try a different name or phone number." : "Register your first patient to get started."
        }
        emptyAction={
          !debouncedSearch &&
          can(staff?.role, "patientCreate") && (
            <Button render={<Link href="/patients/new" />} variant="outline" size="sm">
              Add patient
            </Button>
          )
        }
      />

      {meta && (
        <div className="flex flex-wrap items-center justify-between gap-2 text-sm text-muted-foreground">
          <span>
            Page {meta.page} of {Math.max(1, meta.total_pages)} · {meta.total} patients
          </span>
          <div className="flex gap-2">
            <Button
              variant="outline"
              size="sm"
              disabled={page <= 1}
              onClick={() => router.replace(`${pathname}?${new URLSearchParams({ ...Object.fromEntries(searchParams), page: String(page - 1) })}`)}
            >
              Previous
            </Button>
            <Button
              variant="outline"
              size="sm"
              disabled={page >= meta.total_pages}
              onClick={() => router.replace(`${pathname}?${new URLSearchParams({ ...Object.fromEntries(searchParams), page: String(page + 1) })}`)}
            >
              Next
            </Button>
          </div>
        </div>
      )}
    </div>
  );
}
