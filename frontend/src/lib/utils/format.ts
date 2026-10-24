import { format, formatDistanceToNow, isValid, parseISO } from "date-fns";

export function formatDate(value: string | null | undefined): string {
  if (!value) return "—";
  const date = parseISO(value);
  return isValid(date) ? format(date, "MMM d, yyyy") : value;
}

export function formatDateTime(value: string | null | undefined): string {
  if (!value) return "—";
  const date = parseISO(value);
  return isValid(date) ? format(date, "MMM d, yyyy 'at' h:mm a") : value;
}

export function timeAgo(value: string | null | undefined): string {
  if (!value) return "";
  const date = parseISO(value);
  return isValid(date) ? formatDistanceToNow(date, { addSuffix: true }) : value;
}

/** Local ISO string for a datetime-local input default (avoids UTC drift). */
export function localDateTimeValue(date = new Date()): string {
  const pad = (n: number) => String(n).padStart(2, "0");
  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(
    date.getMinutes()
  )}`;
}

/** Convert datetime-local value to an ISO string the backend can parse. */
export function toIsoFromLocal(value: string): string {
  const date = new Date(value);
  return Number.isNaN(date.getTime()) ? value : date.toISOString();
}
