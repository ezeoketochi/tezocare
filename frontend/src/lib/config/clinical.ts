export const ROUTES = ["Oral", "Sublingual", "Topical", "IV", "IM", "SC", "Inhaled", "Rectal", "Other"];

export const FREQUENCIES = [
  { code: "OD", label: "Once daily" },
  { code: "BD", label: "Twice daily" },
  { code: "TDS", label: "Three times daily" },
  { code: "QDS", label: "Four times daily" },
  { code: "QN", label: "Every night" },
  { code: "BID", label: "Twice a day (12h apart)" },
  { code: "PRN", label: "As needed" },
  { code: "STAT", label: "Immediately (once)" },
  { code: "WOD", label: "Every other day" },
];

export const DOSE_UNITS = ["mg", "g", "mcg", "ml", "L", "units", "tablet(s)", "capsule(s)", "puff(s)", "drop(s)", "sachet(s)"];

export const DURATION_UNITS = ["day(s)", "week(s)", "month(s)"];

export const SEVERITIES = ["mild", "moderate", "severe"];

export const ADHERENCE_OPTIONS = ["Full", "Partial", "Non-adherent"];

export const BLOOD_GLUCOSE_TYPES = ["Fasting", "Random", "Postprandial", "HbA1c"];
