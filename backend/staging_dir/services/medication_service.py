from datetime import date
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.visit import Visit


class MedicationService:

    @staticmethod
    async def get_patient_medications(db: AsyncSession, patient_id: str) -> list[dict]:
        result = await db.execute(
            select(Visit).where(Visit.patient_id == patient_id).order_by(Visit.created_at.desc())
        )
        visits = result.scalars().all()
        all_meds = []
        for v in visits:
            meds = v.medications_dispensed or []
            for m in meds:
                m["visit_id"] = str(v.id)
                m["visit_date"] = v.visit_date.isoformat() if v.visit_date else None
                all_meds.append(m)
        return all_meds

    @staticmethod
    async def get_refills_due(db: AsyncSession, start_date: date, end_date: date) -> list[dict]:
        result = await db.execute(
            select(Visit).order_by(Visit.created_at.desc())
        )
        visits = result.scalars().all()
        refills = []
        for v in visits:
            meds = v.medications_dispensed or []
            for m in meds:
                refill_date_str = m.get("refill_date")
                if refill_date_str:
                    try:
                        refill_date = date.fromisoformat(refill_date_str)
                    except (ValueError, TypeError):
                        continue
                    if start_date <= refill_date <= end_date:
                        refills.append({
                            "visit_id": str(v.id),
                            "patient_id": str(v.patient_id),
                            "drug_name": m.get("drug_name", ""),
                            "dose": m.get("dose", ""),
                            "frequency": m.get("frequency", ""),
                            "refill_date": refill_date_str,
                        })
        return refills
