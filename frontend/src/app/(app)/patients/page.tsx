import { Suspense } from "react";
import { PatientsList } from "@/components/patients/patients-list";

export const metadata = { title: "Patients" };

export default function PatientsPage() {
  return (
    <Suspense>
      <PatientsList />
    </Suspense>
  );
}
