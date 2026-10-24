"use client";

import { Button } from "@/components/ui/button";
import { Skeleton } from "@/components/ui/skeleton";
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert";
import { getErrorMessage } from "@/lib/api/errors";

export interface DataTableColumn<T> {
  header: string;
  cell: (row: T) => React.ReactNode;
  /** Optional mobile card primary line. Falls back to cell(). */
  mobilePrimary?: (row: T) => React.ReactNode;
  className?: string;
}

interface DataTableProps<T> {
  columns: DataTableColumn<T>[];
  rows: T[];
  rowKey: (row: T) => string;
  onRowClick?: (row: T) => void;
  isLoading?: boolean;
  error?: unknown;
  onRetry?: () => void;
  emptyTitle?: string;
  emptyDescription?: string;
  emptyAction?: React.ReactNode;
}

export function DataTable<T>({
  columns,
  rows,
  rowKey,
  onRowClick,
  isLoading,
  error,
  onRetry,
  emptyTitle = "Nothing here yet",
  emptyDescription,
  emptyAction,
}: DataTableProps<T>) {
  if (isLoading) {
    return (
      <div className="space-y-2" aria-busy>
        {Array.from({ length: 6 }).map((_, i) => (
          <Skeleton key={i} className="h-12 w-full" />
        ))}
      </div>
    );
  }

  if (error) {
    return (
      <Alert variant="destructive">
        <AlertTitle>Could not load data</AlertTitle>
        <AlertDescription className="flex flex-wrap items-center justify-between gap-2">
          <span>{getErrorMessage(error)}</span>
          {onRetry && (
            <Button size="sm" variant="outline" onClick={onRetry}>
              Retry
            </Button>
          )}
        </AlertDescription>
      </Alert>
    );
  }

  if (rows.length === 0) {
    return (
      <div className="flex flex-col items-center justify-center gap-3 rounded-card border border-dashed border-line py-14 text-center">
        <p className="text-[15px] leading-[22px] text-title">{emptyTitle}</p>
        {emptyDescription && (
          <p className="max-w-sm text-[13px] leading-[20px] font-light text-muted-foreground">{emptyDescription}</p>
        )}
        {emptyAction}
      </div>
    );
  }

  const clickable = Boolean(onRowClick);

  return (
    <>
      {/* Desktop table */}
      <div className="hidden overflow-x-auto rounded-card border border-line bg-panel md:block">
        <table className="w-full text-sm">
          <thead>
            <tr className="border-b border-line bg-ink/40 text-left">
              {columns.map((col) => (
                <th key={col.header} className={`px-4 py-3 text-xs leading-[16px] font-normal text-muted-foreground ${col.className ?? ""}`}>
                  {col.header}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {rows.map((row) => (
              <tr
                key={rowKey(row)}
                onClick={onRowClick ? () => onRowClick(row) : undefined}
                className={`border-b border-line last:border-0 transition-colors ${
                  clickable ? "cursor-pointer hover:bg-ink/40" : ""
                }`}
              >
                {columns.map((col) => (
                  <td key={col.header} className={`px-4 py-3 align-middle text-[15px] leading-[22px] text-value ${col.className ?? ""}`}>
                    {col.cell(row)}
                  </td>
                ))}
              </tr>
            ))}
          </tbody>
        </table>
      </div>

      {/* Mobile card list */}
      <div className="grid gap-2 md:hidden">
        {rows.map((row) => (
          <button
            key={rowKey(row)}
            type="button"
            disabled={!clickable}
            onClick={onRowClick ? () => onRowClick(row) : undefined}
            className={`w-full rounded-card border border-line bg-panel p-4 text-left text-[15px] leading-[22px] text-value ${
              clickable ? "active:bg-ink/40" : ""
            }`}
          >
            <div className="text-title">
              {columns[0]?.mobilePrimary ? columns[0].mobilePrimary(row) : columns[0]?.cell(row)}
            </div>
            <div className="mt-1 grid gap-0.5 text-[13px] leading-[20px] font-light text-muted-foreground">
              {columns.slice(1).map((col) => (
                <div key={col.header}>
                  <span className="text-xs">{col.header}: </span>
                  {col.cell(row)}
                </div>
              ))}
            </div>
          </button>
        ))}
      </div>
    </>
  );
}
