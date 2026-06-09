from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from app.models.patient import Patient
from app.schemas.patient import PatientCreate, PatientUpdate


class PatientService:

    @staticmethod
    async def create(db: AsyncSession, payload: PatientCreate, registered_by: str) -> Patient:
        patient = Patient(**payload.model_dump(), registered_by=registered_by)
        db.add(patient)
        await db.commit()
        await db.refresh(patient)
        return patient

    @staticmethod
    async def get(db: AsyncSession, patient_id: str) -> Patient | None:
        result = await db.execute(select(Patient).where(Patient.id == patient_id))
        return result.scalar_one_or_none()

    @staticmethod
    async def get_all(db: AsyncSession, skip: int = 0, limit: int = 100) -> list[Patient]:
        result = await db.execute(select(Patient).offset(skip).limit(limit))
        return result.scalars().all()

    @staticmethod
    async def update(db: AsyncSession, patient_id: str, payload: PatientUpdate) -> Patient | None:
        patient = await PatientService.get(db, patient_id)
        if not patient:
            return None
        for key, value in payload.model_dump(exclude_unset=True).items():
            setattr(patient, key, value)
        await db.commit()
        await db.refresh(patient)
        return patient

    @staticmethod
    async def delete(db: AsyncSession, patient_id: str) -> bool:
        patient = await PatientService.get(db, patient_id)
        if not patient:
            return False
        await db.delete(patient)
        await db.commit()
        return True
