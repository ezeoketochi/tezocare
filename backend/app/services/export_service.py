import csv
import io
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.patient import Patient
from app.models.visit import Visit


class ExportService:

    @staticmethod
    async def export_patients_csv(db: AsyncSession) -> str:
        output = io.StringIO()
        writer = csv.writer(output)
        result = await db.execute(select(Patient))
        patients = result.scalars().all()
        writer.writerow(["ID", "First Name", "Last Name", "Date of Birth", "Gender", "Phone", "Address", "State", "City"])
        for p in patients:
            writer.writerow([p.id, p.first_name, p.last_name, p.date_of_birth, p.gender.value, p.phone, p.address, p.state, p.city])
        return output.getvalue()

    @staticmethod
    async def export_visits_csv(db: AsyncSession, patient_id: str | None = None) -> str:
        output = io.StringIO()
        writer = csv.writer(output)
        query = select(Visit)
        if patient_id:
            query = query.where(Visit.patient_id == patient_id)
        result = await db.execute(query)
        visits = result.scalars().all()
        writer.writerow(["ID", "Patient ID", "Visit Number", "Visit Date", "Status"])
        for v in visits:
            writer.writerow([v.id, v.patient_id, v.visit_number, v.visit_date, v.status.value if v.status else ""])
        return output.getvalue()
