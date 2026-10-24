import type { UseFormSetError, FieldValues, FieldPath } from "react-hook-form";
import { ApiError } from "@/lib/api/errors";

export function applyFieldErrors<T extends FieldValues>(
  setError: UseFormSetError<T>,
  error: unknown
): boolean {
  if (!(error instanceof ApiError) || Object.keys(error.fieldErrors).length === 0) return false;
  for (const [field, message] of Object.entries(error.fieldErrors)) {
    setError(field as FieldPath<T>, { type: "server", message });
  }
  return true;
}
