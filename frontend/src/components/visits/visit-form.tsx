"use client";

import { useEffect } from "react";
import { useFieldArray, useForm, useWatch, type Control, type UseFormReturn } from "react-hook-form";
import { zodResolver } from "@hookform/resolvers/zod";
import { format, parseISO } from "date-fns";
import {
  Activity,
  CalendarClock,
  ClipboardList,
  FlaskConical,
  Lightbulb,
  MessageSquareText,
  Pill,
  Plus,
  Send,
  Stethoscope,
  Trash2,
} from "lucide-react";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card";
import { Input } from "@/components/ui/input";
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from "@/components/ui/select";
import { Switch } from "@/components/ui/switch";
import { Textarea } from "@/components/ui/textarea";
import { FieldError, Form, FormControl, FormDescription, FormField, FormItem, FormLabel } from "@/components/ui/form-field";
import { TagInput } from "@/components/common/tag-input";
import {
  ADHERENCE_OPTIONS,
  BLOOD_GLUCOSE_TYPES,
  DOSE_UNITS,
  DURATION_UNITS,
  FREQUENCIES,
  ROUTES,
  SEVERITIES,
} from "@/lib/config/clinical";
import { visitFormSchema, type VisitFormValues } from "@/lib/schemas/visit";
import type { Visit } from "@/lib/features/visits/types";

const numToStr = (v: number | null | undefined): string => (v === null || v === undefined ? "" : String(v));
const strOrNull = (v: string | undefined | null): string | null => (!v || v.trim() === "" ? null : v.trim());
const numOrNull = (v: string | undefined | null): number | null => (v == null || v.trim() === "" || !Number.isFinite(Number(v)) ? null : Number(v));

export function visitToFormValues(v: Visit): VisitFormValues {
  return {
    visit_date: v.visit_date ? format(parseISO(v.visit_date), "yyyy-MM-dd'T'HH:mm") : "",
    chief_complaints: (v.chief_complaints ?? []).map((c) => ({ complaint: c.complaint ?? "", duration: c.duration ?? "" })),
    medication_history: {
      past_medications: v.medication_history?.past_medications ?? [],
      current_medications: v.medication_history?.current_medications ?? [],
      adherence: v.medication_history?.adherence ?? "",
      non_adherence_reason: v.medication_history?.non_adherence_reason ?? "",
    },
    vitals: {
      bp_systolic: numToStr(v.vitals?.bp_systolic),
      bp_diastolic: numToStr(v.vitals?.bp_diastolic),
      heart_rate: numToStr(v.vitals?.heart_rate),
      temperature: numToStr(v.vitals?.temperature),
      respiratory_rate: numToStr(v.vitals?.respiratory_rate),
      sp_o2: numToStr(v.vitals?.sp_o2),
      weight: numToStr(v.vitals?.weight),
      height: numToStr(v.vitals?.height),
      bmi: numToStr(v.vitals?.bmi),
      blood_glucose: numToStr(v.vitals?.blood_glucose),
      blood_glucose_type: v.vitals?.blood_glucose_type ?? "",
    },
    test_results: (v.test_results ?? []).map((t) => ({ test_name: t.test_name ?? "", result: t.result ?? "" })),
    clinical_assessment: {
      suspected_diagnosis: v.clinical_assessment?.suspected_diagnosis ?? "",
      severity: v.clinical_assessment?.severity ?? "",
      pharmacist_notes: v.clinical_assessment?.pharmacist_notes ?? "",
    },
    medications_dispensed: (v.medications_dispensed ?? []).map((m) => ({
      drug_name: m.drug_name ?? "",
      dose_amount: numToStr(m.dose_amount),
      dose_unit: m.dose_unit ?? "",
      route: m.route ?? "",
      frequency: m.frequency ?? "",
      frequency_code: m.frequency_code ?? "",
      duration_amount: numToStr(m.duration_amount),
      duration_unit: m.duration_unit ?? "",
      total_quantity: numToStr(m.total_quantity),
      instructions: m.instructions ?? "",
      date_dispensed: m.date_dispensed ?? "",
      expected_finish_date: m.expected_finish_date ?? "",
      refill_date: m.refill_date ?? "",
      is_recurrent: Boolean(m.is_recurrent),
      recurrence_interval_days: numToStr(m.recurrence_interval_days),
    })),
    counselling_advice: v.counselling_advice ?? "",
    follow_up: {
      required: Boolean(v.follow_up?.required),
      scheduled_date: v.follow_up?.scheduled_date ?? "",
      is_recurrent: Boolean(v.follow_up?.is_recurrent),
      recurrence_interval_days: numToStr(v.follow_up?.recurrence_interval_days),
    },
    referral: {
      is_referred: Boolean(v.referral?.is_referred),
      destination: v.referral?.destination ?? "",
      reason: v.referral?.reason ?? "",
    },
  };
}

export function visitFormToPayload(values: VisitFormValues): Record<string, unknown> {
  let visitDateIso = values.visit_date;
  const d = new Date(values.visit_date);
  if (!Number.isNaN(d.getTime())) visitDateIso = d.toISOString();

  return {
    visit_date: visitDateIso,
    chief_complaints: values.chief_complaints.filter((c) => c.complaint.trim()).map((c) => ({ complaint: c.complaint.trim(), duration: c.duration.trim() })),
    medication_history: {
      past_medications: values.medication_history.past_medications,
      current_medications: values.medication_history.current_medications,
      adherence: strOrNull(values.medication_history.adherence),
      non_adherence_reason: strOrNull(values.medication_history.non_adherence_reason),
    },
    vitals: {
      bp_systolic: numOrNull(values.vitals.bp_systolic),
      bp_diastolic: numOrNull(values.vitals.bp_diastolic),
      heart_rate: numOrNull(values.vitals.heart_rate),
      temperature: numOrNull(values.vitals.temperature),
      respiratory_rate: numOrNull(values.vitals.respiratory_rate),
      sp_o2: numOrNull(values.vitals.sp_o2),
      weight: numOrNull(values.vitals.weight),
      height: numOrNull(values.vitals.height),
      bmi: numOrNull(values.vitals.bmi),
      blood_glucose: numOrNull(values.vitals.blood_glucose),
      blood_glucose_type: strOrNull(values.vitals.blood_glucose_type),
    },
    test_results: values.test_results.filter((t) => t.test_name.trim()).map((t) => ({ test_name: t.test_name.trim(), result: t.result.trim() })),
    clinical_assessment: {
      suspected_diagnosis: strOrNull(values.clinical_assessment.suspected_diagnosis),
      severity: strOrNull(values.clinical_assessment.severity),
      pharmacist_notes: strOrNull(values.clinical_assessment.pharmacist_notes),
    },
    medications_dispensed: values.medications_dispensed.map((m) => ({
      drug_name: m.drug_name.trim(),
      dose_amount: numOrNull(m.dose_amount),
      dose_unit: m.dose_unit,
      route: m.route,
      frequency: m.frequency,
      frequency_code: m.frequency_code,
      duration_amount: numOrNull(m.duration_amount),
      duration_unit: m.duration_unit,
      total_quantity: numOrNull(m.total_quantity),
      instructions: strOrNull(m.instructions),
      date_dispensed: strOrNull(m.date_dispensed),
      expected_finish_date: strOrNull(m.expected_finish_date),
      refill_date: strOrNull(m.refill_date),
      is_recurrent: m.is_recurrent,
      recurrence_interval_days: numOrNull(m.recurrence_interval_days),
    })),
    counselling_advice: strOrNull(values.counselling_advice),
    follow_up: {
      required: values.follow_up.required,
      scheduled_date: strOrNull(values.follow_up.scheduled_date),
      is_recurrent: values.follow_up.is_recurrent,
      recurrence_interval_days: numOrNull(values.follow_up.recurrence_interval_days),
    },
  };
}

function SuggestionSelect({
  field,
  options,
  placeholder = "Select…",
}: {
  field: { value: string; onChange: (v: unknown) => void };
  options: string[];
  placeholder?: string;
}) {
  return (
    <Select value={field.value} onValueChange={(v) => field.onChange(v ?? "")}>
      <SelectTrigger className="w-full">
        <SelectValue placeholder={placeholder} />
      </SelectTrigger>
      <SelectContent>
        {options.map((o) => (
          <SelectItem key={o} value={o}>
            {o}
          </SelectItem>
        ))}
      </SelectContent>
    </Select>
  );
}

function MedicationRecurrenceIntervalField({
  control,
  index,
}: {
  control: Control<VisitFormValues>;
  index: number;
}) {
  const isRecurrent = useWatch({ control, name: `medications_dispensed.${index}.is_recurrent` });
  if (!isRecurrent) return null;
  return (
    <FormField
      control={control}
      name={`medications_dispensed.${index}.recurrence_interval_days`}
      render={({ field }) => (
        <FormItem>
          <FormLabel>Recurrence interval (days)</FormLabel>
          <FormControl>
            <Input inputMode="numeric" {...field} />
          </FormControl>
          <FieldError />
        </FormItem>
      )}
    />
  );
}

export function VisitForm({
  initial,
  submitting,
  onSubmit,
}: {
  initial: Visit;
  submitting: boolean;
  onSubmit: (values: VisitFormValues) => void;
}) {
  const form: UseFormReturn<VisitFormValues> = useForm<VisitFormValues>({
    resolver: zodResolver(visitFormSchema),
    defaultValues: visitToFormValues(initial),
  });

  const complaints = useFieldArray({ control: form.control, name: "chief_complaints" });
  const tests = useFieldArray({ control: form.control, name: "test_results" });
  const meds = useFieldArray({ control: form.control, name: "medications_dispensed" });

  const followUpRequired = useWatch({ control: form.control, name: "follow_up.required" });
  const followUpRecurrent = useWatch({ control: form.control, name: "follow_up.is_recurrent" });
  const adherence = useWatch({ control: form.control, name: "medication_history.adherence" });
  const weight = useWatch({ control: form.control, name: "vitals.weight" });
  const height = useWatch({ control: form.control, name: "vitals.height" });

  // Auto-calc BMI from kg and cm.
  useEffect(() => {
    const w = Number(weight);
    const h = Number(height);
    if (w > 0 && h > 0) {
      form.setValue("vitals.bmi", (w / Math.pow(h / 100, 2)).toFixed(1));
    }
  }, [weight, height, form]);

  return (
    <Form {...form}>
      <form onSubmit={form.handleSubmit(onSubmit)} className="grid gap-5 pb-24">
        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle icon={ClipboardList}>Visit</CardTitle>
            <Badge variant="outline">Visit #{initial.visit_number}</Badge>
          </CardHeader>
          <CardContent>
            <FormField
              control={form.control}
              name="visit_date"
              render={({ field }) => (
                <FormItem className="max-w-xs">
                  <FormLabel>Visit date & time</FormLabel>
                  <FormControl>
                    <Input type="datetime-local" {...field} />
                  </FormControl>
                  <FieldError />
                </FormItem>
              )}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle icon={MessageSquareText}>Chief complaints</CardTitle>
            <Button type="button" variant="outline" size="sm" onClick={() => complaints.append({ complaint: "", duration: "" })}>
              <Plus className="size-4" /> Add
            </Button>
          </CardHeader>
          <CardContent className="space-y-3">
            {complaints.fields.map((row, i) => (
              <div key={row.id} className="flex items-start gap-2">
                <FormField
                  control={form.control}
                  name={`chief_complaints.${i}.complaint`}
                  render={({ field }) => (
                    <FormItem className="flex-1">
                      <FormControl>
                        <Input placeholder="Complaint (e.g. headache)" {...field} />
                      </FormControl>
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name={`chief_complaints.${i}.duration`}
                  render={({ field }) => (
                    <FormItem className="w-40">
                      <FormControl>
                        <Input placeholder="Duration" {...field} />
                      </FormControl>
                    </FormItem>
                  )}
                />
                <Button type="button" variant="ghost" size="icon" aria-label="Remove" onClick={() => complaints.remove(i)}>
                  <Trash2 className="size-4" />
                </Button>
              </div>
            ))}
            {complaints.fields.length === 0 && <p className="text-sm text-muted-foreground">No complaints recorded.</p>}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle icon={Pill}>Medication history</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4">
            <FormField
              control={form.control}
              name="medication_history.past_medications"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Past medications</FormLabel>
                  <TagInput value={field.value} onChange={field.onChange} placeholder="Add, press Enter" />
                </FormItem>
              )}
            />
            <FormField
              control={form.control}
              name="medication_history.current_medications"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Current medications</FormLabel>
                  <TagInput value={field.value} onChange={field.onChange} placeholder="Add, press Enter" />
                </FormItem>
              )}
            />
            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="medication_history.adherence"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Adherence</FormLabel>
                    <SuggestionSelect field={field} options={ADHERENCE_OPTIONS} />
                  </FormItem>
                )}
              />
              {adherence && adherence !== "Full" && (
                <FormField
                  control={form.control}
                  name="medication_history.non_adherence_reason"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Reason for non-adherence</FormLabel>
                      <FormControl>
                        <Input {...field} />
                      </FormControl>
                    </FormItem>
                  )}
                />
              )}
            </div>
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle icon={Activity}>Vitals</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4 sm:grid-cols-3">
            {(
              [
                ["bp_systolic", "BP systolic (mmHg)"],
                ["bp_diastolic", "BP diastolic (mmHg)"],
                ["heart_rate", "Heart rate (bpm)"],
                ["temperature", "Temperature (°C)"],
                ["respiratory_rate", "Resp. rate (/min)"],
                ["sp_o2", "SpO₂ (%)"],
                ["weight", "Weight (kg)"],
                ["height", "Height (cm)"],
                ["bmi", "BMI (auto)"],
                ["blood_glucose", "Blood glucose"],
              ] as const
            ).map(([name, label]) => (
              <FormField
                key={name}
                control={form.control}
                name={`vitals.${name}`}
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>{label}</FormLabel>
                    <FormControl>
                      <Input inputMode="decimal" disabled={name === "bmi"} {...field} />
                    </FormControl>
                    <FieldError />
                  </FormItem>
                )}
              />
            ))}
            <FormField
              control={form.control}
              name="vitals.blood_glucose_type"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Glucose test type</FormLabel>
                  <SuggestionSelect field={field} options={BLOOD_GLUCOSE_TYPES} />
                </FormItem>
              )}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle icon={FlaskConical}>Test results</CardTitle>
            <Button type="button" variant="outline" size="sm" onClick={() => tests.append({ test_name: "", result: "" })}>
              <Plus className="size-4" /> Add
            </Button>
          </CardHeader>
          <CardContent className="space-y-3">
            {tests.fields.map((row, i) => (
              <div key={row.id} className="flex items-start gap-2">
                <FormField
                  control={form.control}
                  name={`test_results.${i}.test_name`}
                  render={({ field }) => (
                    <FormItem className="flex-1">
                      <FormControl>
                        <Input placeholder="Test (e.g. Widal)" {...field} />
                      </FormControl>
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name={`test_results.${i}.result`}
                  render={({ field }) => (
                    <FormItem className="flex-1">
                      <FormControl>
                        <Input placeholder="Result" {...field} />
                      </FormControl>
                    </FormItem>
                  )}
                />
                <Button type="button" variant="ghost" size="icon" aria-label="Remove" onClick={() => tests.remove(i)}>
                  <Trash2 className="size-4" />
                </Button>
              </div>
            ))}
            {tests.fields.length === 0 && <p className="text-sm text-muted-foreground">No tests recorded.</p>}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle icon={Stethoscope}>Clinical assessment</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4">
            <div className="grid gap-4 sm:grid-cols-2">
              <FormField
                control={form.control}
                name="clinical_assessment.suspected_diagnosis"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Suspected diagnosis</FormLabel>
                    <FormControl>
                      <Input {...field} />
                    </FormControl>
                  </FormItem>
                )}
              />
              <FormField
                control={form.control}
                name="clinical_assessment.severity"
                render={({ field }) => (
                  <FormItem>
                    <FormLabel>Severity</FormLabel>
                    <SuggestionSelect field={field} options={SEVERITIES} />
                  </FormItem>
                )}
              />
            </div>
            <FormField
              control={form.control}
              name="clinical_assessment.pharmacist_notes"
              render={({ field }) => (
                <FormItem>
                  <FormLabel>Pharmacist notes</FormLabel>
                  <FormControl>
                    <Textarea rows={3} {...field} />
                  </FormControl>
                </FormItem>
              )}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader className="flex-row items-center justify-between">
            <CardTitle icon={Pill}>Medications dispensed</CardTitle>
            <Button
              type="button"
              variant="outline"
              size="sm"
              onClick={() =>
                meds.append({
                  drug_name: "",
                  dose_amount: "",
                  dose_unit: "mg",
                  route: "Oral",
                  frequency: "",
                  frequency_code: "",
                  duration_amount: "",
                  duration_unit: "day(s)",
                  total_quantity: "",
                  instructions: "",
                  date_dispensed: format(new Date(), "yyyy-MM-dd"),
                  expected_finish_date: "",
                  refill_date: "",
                  is_recurrent: false,
                  recurrence_interval_days: "",
                })
              }
            >
              <Plus className="size-4" /> Add medication
            </Button>
          </CardHeader>
          <CardContent className="space-y-4">
            {meds.fields.map((row, i) => (
              <div key={row.id} className="space-y-3 rounded-card border border-line bg-ink/40 p-4">
                <div className="flex items-start gap-2">
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.drug_name`}
                    render={({ field }) => (
                      <FormItem className="flex-1">
                        <FormLabel>Drug name</FormLabel>
                        <FormControl>
                          <Input placeholder="e.g. Amoxicillin" {...field} />
                        </FormControl>
                        <FieldError />
                      </FormItem>
                    )}
                  />
                  <Button
                    type="button"
                    variant="ghost"
                    size="icon"
                    aria-label="Remove medication"
                    className="mt-6"
                    onClick={() => meds.remove(i)}
                  >
                    <Trash2 className="size-4" />
                  </Button>
                </div>
                <div className="grid gap-3 sm:grid-cols-4">
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.dose_amount`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Dose</FormLabel>
                        <div className="flex gap-1">
                          <FormControl>
                            <Input inputMode="decimal" placeholder="500" {...field} />
                          </FormControl>
                          <FormField
                            control={form.control}
                            name={`medications_dispensed.${i}.dose_unit`}
                            render={({ field: u }) => (
                              <FormItem className="w-28">
                                <SuggestionSelect field={u} options={DOSE_UNITS} />
                              </FormItem>
                            )}
                          />
                        </div>
                        <FieldError />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.route`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Route</FormLabel>
                        <SuggestionSelect field={field} options={ROUTES} />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.frequency_code`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Frequency</FormLabel>
                        <Select
                          value={field.value}
                          onValueChange={(code) => {
                            field.onChange(code ?? "");
                            const f = FREQUENCIES.find((x) => x.code === code);
                            form.setValue(`medications_dispensed.${i}.frequency`, f?.label ?? "");
                          }}
                        >
                          <SelectTrigger className="w-full">
                            <SelectValue placeholder="Select" />
                          </SelectTrigger>
                          <SelectContent>
                            {FREQUENCIES.map((f) => (
                              <SelectItem key={f.code} value={f.code}>
                                {f.code} — {f.label}
                              </SelectItem>
                            ))}
                          </SelectContent>
                        </Select>
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.duration_amount`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Duration</FormLabel>
                        <div className="flex gap-1">
                          <FormControl>
                            <Input inputMode="decimal" placeholder="7" {...field} />
                          </FormControl>
                          <FormField
                            control={form.control}
                            name={`medications_dispensed.${i}.duration_unit`}
                            render={({ field: u }) => (
                              <FormItem className="w-28">
                                <SuggestionSelect field={u} options={DURATION_UNITS} />
                              </FormItem>
                            )}
                          />
                        </div>
                        <FieldError />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.total_quantity`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Total qty</FormLabel>
                        <FormControl>
                          <Input inputMode="numeric" {...field} />
                        </FormControl>
                        <FieldError />
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.date_dispensed`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Dispensed date</FormLabel>
                        <FormControl>
                          <Input type="date" {...field} />
                        </FormControl>
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.refill_date`}
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Refill date</FormLabel>
                        <FormControl>
                          <Input type="date" {...field} />
                        </FormControl>
                      </FormItem>
                    )}
                  />
                  <FormField
                    control={form.control}
                    name={`medications_dispensed.${i}.is_recurrent`}
                    render={({ field }) => (
                      <FormItem className="flex flex-col gap-1.5">
                        <FormLabel>Recurrent</FormLabel>
                        <div className="flex items-center gap-2">
                          <Switch checked={field.value} onCheckedChange={(c) => field.onChange(Boolean(c))} />
                          <FormDescription className="text-xs">{field.value ? "Auto-repeats" : "One-off"}</FormDescription>
                        </div>
                      </FormItem>
                    )}
                  />
                </div>
                <MedicationRecurrenceIntervalField control={form.control} index={i} />
                <FormField
                  control={form.control}
                  name={`medications_dispensed.${i}.instructions`}
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Instructions (sig)</FormLabel>
                      <FormControl>
                        <Input placeholder="e.g. Take after meals" {...field} />
                      </FormControl>
                    </FormItem>
                  )}
                />
              </div>
            ))}
            {meds.fields.length === 0 && (
              <p className="text-sm text-muted-foreground">
                No medications dispensed. Add rows here — they feed the patient&apos;s medication list and refill tracking.
              </p>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle icon={Lightbulb}>Counselling advice</CardTitle>
          </CardHeader>
          <CardContent>
            <FormField
              control={form.control}
              name="counselling_advice"
              render={({ field }) => (
                <FormItem>
                  <FormControl>
                    <Textarea rows={3} placeholder="Advice given to the patient…" {...field} />
                  </FormControl>
                </FormItem>
              )}
            />
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle icon={CalendarClock}>Follow-up</CardTitle>
          </CardHeader>
          <CardContent className="grid gap-4">
            <FormField
              control={form.control}
              name="follow_up.required"
              render={({ field }) => (
                <FormItem className="flex items-center gap-2">
                  <FormLabel className="mb-0">Follow-up required</FormLabel>
                  <Switch checked={field.value} onCheckedChange={(c) => field.onChange(Boolean(c))} />
                </FormItem>
              )}
            />
            {followUpRequired && (
              <div className="grid gap-4 sm:grid-cols-3">
                <FormField
                  control={form.control}
                  name="follow_up.scheduled_date"
                  render={({ field }) => (
                    <FormItem>
                      <FormLabel>Scheduled date</FormLabel>
                      <FormControl>
                        <Input type="date" {...field} />
                      </FormControl>
                      <FieldError />
                    </FormItem>
                  )}
                />
                <FormField
                  control={form.control}
                  name="follow_up.is_recurrent"
                  render={({ field }) => (
                    <FormItem className="flex items-center gap-2">
                      <FormLabel className="mb-0">Recurring</FormLabel>
                      <Switch checked={field.value} onCheckedChange={(c) => field.onChange(Boolean(c))} />
                    </FormItem>
                  )}
                />
                {followUpRecurrent && (
                  <FormField
                    control={form.control}
                    name="follow_up.recurrence_interval_days"
                    render={({ field }) => (
                      <FormItem>
                        <FormLabel>Interval (days)</FormLabel>
                        <FormControl>
                          <Input inputMode="numeric" {...field} />
                        </FormControl>
                        <FieldError />
                      </FormItem>
                    )}
                  />
                )}
              </div>
            )}
            {initial.follow_up?.is_done && (
              <p className="text-sm text-muted-foreground">
                Follow-up completed {formatDateSafe(initial.follow_up.date_completed)} — outcome: {initial.follow_up.outcome ?? "—"}
              </p>
            )}
          </CardContent>
        </Card>

        {initial.referral?.is_referred && (
          <Card>
            <CardHeader>
              <CardTitle icon={Send}>Referral</CardTitle>
            </CardHeader>
            <CardContent className="text-sm">
              <p>
                Referred to <span className="font-medium">{initial.referral.destination}</span>
              </p>
              {initial.referral.reason && <p className="text-muted-foreground">Reason: {initial.referral.reason}</p>}
            </CardContent>
          </Card>
        )}

        <div className="sticky bottom-0 -mx-3.5 flex gap-2 border-t border-line bg-surface/95 px-3.5 py-3 backdrop-blur md:-mx-6 md:px-6">
          <Button type="submit" disabled={submitting}>
            {submitting ? "Saving…" : "Save visit"}
          </Button>
          <Button type="button" variant="outline" disabled={submitting} onClick={() => form.reset(visitToFormValues(initial))}>
            Discard changes
          </Button>
        </div>
      </form>
    </Form>
  );
}

function formatDateSafe(value: string | null | undefined): string {
  if (!value) return "—";
  try {
    return format(parseISO(value), "MMM d, yyyy");
  } catch {
    return value;
  }
}
