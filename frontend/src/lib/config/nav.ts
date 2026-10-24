import {
  Bell,
  ClipboardList,
  LayoutDashboard,
  Pill,
  Plus,
  RefreshCcw,
  Settings,
  Users,
} from "lucide-react";
import type { LucideIcon } from "lucide-react";
import type { StaffRole } from "@/lib/api/types";

export interface NavItem {
  title: string;
  href: string;
  icon: LucideIcon;
  minRole?: StaffRole;
  matchExact?: boolean;
}

export const PRIMARY_NAV: NavItem[] = [
  { title: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { title: "Patients", href: "/patients", icon: Users },
  { title: "Due Refills", href: "/refills", icon: RefreshCcw },
  { title: "Follow-ups", href: "/follow-ups", icon: ClipboardList },
  { title: "Medications", href: "/medications", icon: Pill },
  { title: "Notifications", href: "/notifications", icon: Bell },
  { title: "Settings", href: "/settings", icon: Settings },
];

// Flutter bottom-nav parity for small screens.
export const MOBILE_NAV: NavItem[] = [
  { title: "Dashboard", href: "/dashboard", icon: LayoutDashboard },
  { title: "Patients", href: "/patients", icon: Users },
  { title: "Refills", href: "/refills", icon: RefreshCcw },
  { title: "Follow-ups", href: "/follow-ups", icon: ClipboardList },
  { title: "Settings", href: "/settings", icon: Settings },
];

export interface SectionCta {
  label: string;
  href: string;
  caption: string;
  icon: LucideIcon;
}

const STAFF_CTA: SectionCta = {
  label: "New team member",
  href: "/settings/staff/new",
  caption: "Add a pharmacist or data-entry user to this pharmacy.",
  icon: Plus,
};

const PATIENT_CTA: SectionCta = {
  label: "New patient",
  href: "/patients/new",
  caption: "Register someone so visits and refills can be tracked.",
  icon: Plus,
};

export function sectionCta(pathname: string, role?: StaffRole): SectionCta {
  if (pathname.startsWith("/settings/staff") && role === "admin") return STAFF_CTA;
  return PATIENT_CTA;
}

export function isActiveNav(item: NavItem, pathname: string): boolean {
  if (item.matchExact) return pathname === item.href;
  return pathname === item.href || pathname.startsWith(`${item.href}/`);
}

const ROUTE_LABELS: { prefix: string; label: string }[] = [
  { prefix: "/dashboard", label: "Dashboard" },
  { prefix: "/patients", label: "Patients" },
  { prefix: "/refills", label: "Due Refills" },
  { prefix: "/follow-ups", label: "Follow-ups" },
  { prefix: "/medications", label: "Medications" },
  { prefix: "/notifications", label: "Notifications" },
  { prefix: "/settings/staff", label: "Team" },
  { prefix: "/settings", label: "Settings" },
];

const SEGMENT_LABELS: Record<string, string> = {
  new: "New",
  edit: "Edit",
  visits: "Visits",
};

/** Mongo-style ids and numeric primary keys, i.e. anything that is not a route word. */
function isIdSegment(segment: string): boolean {
  return /^\d+$/.test(segment) || /^[0-9a-f]{12,}$/i.test(segment);
}

/** Breadcrumb trail (Home / Section / Detail) built from the pathname. */
export function breadcrumbs(pathname: string): string[] {
  const segments = pathname.split("/").filter(Boolean);
  if (segments.length === 0) return ["Home"];

  const trail = ["Home"];
  let consumed = 0;
  for (const route of ROUTE_LABELS) {
    const parts = route.prefix.split("/").filter(Boolean);
    if (parts.every((p, i) => segments[i] === p)) {
      trail.push(route.label);
      consumed = parts.length;
      break;
    }
  }

  for (const segment of segments.slice(consumed)) {
    if (SEGMENT_LABELS[segment]) {
      trail.push(SEGMENT_LABELS[segment]);
    } else if (isIdSegment(segment)) {
      trail.push(trail.at(-1) === "Visits" ? "Visit" : "Details");
    }
  }
  return trail;
}
