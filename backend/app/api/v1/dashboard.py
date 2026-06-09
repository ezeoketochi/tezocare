from datetime import date, timedelta
from fastapi import APIRouter, Depends, Query
from sqlalchemy import select, func, cast, Date, and_, or_
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.database import get_db
from app.core.role_checker import require_role
from app.core.security import get_current_user
from app.models.staff import Staff, StaffRole
from app.models.patient import Patient
from app.models.visit import Visit, VisitStatus
from app.schemas.common import APIResponse

router = APIRouter()


@router.get("/summary")
async def dashboard_summary(
    db: AsyncSession = Depends(get_db),
    current_staff: Staff = Depends(require_role(StaffRole.admin, StaffRole.pharmacist)),
):
    patients_count = await db.execute(select(func.count(Patient.id)))
    total_patients = patients_count.scalar()

    today = date.today()
    visits_today_count = await db.execute(
        select(func.count(Visit.id)).where(cast(Visit.visit_date, Date) == today)
    )
    visits_today = visits_today_count.scalar()

    follow_ups_pending_count = await db.execute(
        select(func.count(Visit.id)).where(
            and_(
                Visit.follow_up['required'].astext == 'true',
                or_(
                    Visit.follow_up['is_done'].astext == 'false',
                    Visit.follow_up['is_done'].astext.is_(None),
                ),
            )
        )
    )
    follow_ups_pending = follow_ups_pending_count.scalar()

    three_days_from_now = today + timedelta(days=3)

    recent_result = await db.execute(
        select(Visit).order_by(Visit.created_at.desc()).limit(5)
    )
    recent_visits = recent_result.scalars().all()

    recent_patients = []
    for v in recent_visits:
        recent_patients.append({
            "visit_id": str(v.id),
            "patient_id": str(v.patient_id),
            "visit_date": v.visit_date.isoformat() if v.visit_date else None,
            "status": v.status.value if v.status else None,
        })

    refills_due = []
    upcoming_refills = []
    all_visits_result = await db.execute(
        select(Visit).order_by(Visit.created_at.desc())
    )
    all_visits = all_visits_result.scalars().all()
    for v in all_visits:
        meds = v.medications_dispensed or []
        for m in meds:
            refill_date_str = m.get("refill_date")
            drug_name = m.get("drug_name", "")
            if refill_date_str and drug_name:
                try:
                    refill_date = date.fromisoformat(refill_date_str)
                except (ValueError, TypeError):
                    continue
                if today <= refill_date <= three_days_from_now:
                    refills_due.append({
                        "visit_id": str(v.id),
                        "patient_id": str(v.patient_id),
                        "drug_name": drug_name,
                        "dose": m.get("dose", ""),
                        "refill_date": refill_date_str,
                    })
                if refill_date >= today:
                    upcoming_refills.append({
                        "visit_id": str(v.id),
                        "patient_id": str(v.patient_id),
                        "drug_name": drug_name,
                        "dose": m.get("dose", ""),
                        "refill_date": refill_date_str,
                    })

    upcoming_refills = sorted(upcoming_refills, key=lambda x: x["refill_date"])[:5]

    return APIResponse(
        success=True,
        message="Dashboard summary retrieved",
        data={
            "total_patients": total_patients,
            "visits_today": visits_today,
            "follow_ups_pending": follow_ups_pending,
            "refills_due_soon": refills_due,
            "recent_patients": recent_patients,
            "upcoming_refills": upcoming_refills,
        },
    )


@router.get("/due-refills")
async def due_refills(
    days: int | None = Query(default=None, ge=0, le=30),
    db: AsyncSession = Depends(get_db),
    current_staff: Staff = Depends(get_current_user),
):
    today = date.today()
    has_limit = days is not None
    if has_limit:
        cutoff = today + timedelta(days=days)

    result = await db.execute(
        select(Visit, Patient, Staff)
        .join(Patient, Visit.patient_id == Patient.id)
        .join(Staff, Visit.staff_id == Staff.id)
        .where(Visit.status.in_([VisitStatus.active, VisitStatus.completed, VisitStatus.follow_up_pending]))
        .order_by(Visit.visit_date.desc())
    )
    rows = result.all()

    refills = []
    for visit, patient, staff in rows:
        meds = visit.medications_dispensed or []
        for m in meds:
            refill_date_str = m.get("refill_date")
            if not refill_date_str:
                continue
            try:
                refill_date = date.fromisoformat(refill_date_str)
            except (ValueError, TypeError):
                continue
            if has_limit and refill_date > cutoff:
                continue

            days_until = (refill_date - today).days
            if days_until < 0:
                refill_status = "overdue"
            elif days_until == 0:
                refill_status = "due_today"
            else:
                refill_status = "upcoming"

            refills.append({
                "patient_id": str(patient.id),
                "patient_name": f"{patient.first_name} {patient.last_name}",
                "patient_phone": patient.phone,
                "visit_id": str(visit.id),
                "visit_date": visit.visit_date.isoformat() if visit.visit_date else None,
                "drug_name": m.get("drug_name", ""),
                "dose": m.get("dose", ""),
                "frequency": m.get("frequency", ""),
                "duration": m.get("duration", ""),
                "date_dispensed": m.get("date_dispensed"),
                "refill_date": refill_date_str,
                "days_until_refill": days_until,
                "refill_status": refill_status,
                "prescribed_by": staff.name,
            })

    refills.sort(key=lambda x: x["refill_date"])

    overdue = sum(1 for r in refills if r["refill_status"] == "overdue")
    due_today = sum(1 for r in refills if r["refill_status"] == "due_today")
    upcoming = sum(1 for r in refills if r["refill_status"] == "upcoming")

    return APIResponse(
        success=True,
        message="Due refills retrieved",
        data={
            "total": len(refills),
            "overdue": overdue,
            "due_today": due_today,
            "upcoming": upcoming,
            "refills": refills,
        },
    )


@router.get("/due-followups")
async def due_followups(
    days: int | None = Query(default=None, ge=0, le=30),
    db: AsyncSession = Depends(get_db),
    current_staff: Staff = Depends(get_current_user),
):
    today = date.today()
    has_limit = days is not None
    if has_limit:
        cutoff = today + timedelta(days=days)

    result = await db.execute(
        select(Visit, Patient, Staff)
        .join(Patient, Visit.patient_id == Patient.id)
        .join(Staff, Visit.staff_id == Staff.id)
        .where(Visit.status.in_([VisitStatus.active, VisitStatus.follow_up_pending]))
        .order_by(Visit.visit_date.desc())
    )
    rows = result.all()

    followups = []
    for visit, patient, staff in rows:
        fu = visit.follow_up or {}
        if fu.get("is_done", False):
            continue

        scheduled_date_str = fu.get("scheduled_date")
        if not scheduled_date_str:
            continue

        try:
            scheduled_date = date.fromisoformat(scheduled_date_str)
        except (ValueError, TypeError):
            continue

        if has_limit and scheduled_date > cutoff:
            continue

        days_until = (scheduled_date - today).days
        if days_until < 0:
            followup_status = "overdue"
        elif days_until == 0:
            followup_status = "due_today"
        else:
            followup_status = "upcoming"

        meds_dispensed = []
        for m in (visit.medications_dispensed or []):
            meds_dispensed.append({
                "drug_name": m.get("drug_name", ""),
                "dose": m.get("dose", ""),
                "frequency": m.get("frequency", ""),
            })

        assessment = visit.clinical_assessment or {}

        followups.append({
            "patient_id": str(patient.id),
            "patient_name": f"{patient.first_name} {patient.last_name}",
            "patient_phone": patient.phone,
            "visit_id": str(visit.id),
            "visit_date": visit.visit_date.isoformat() if visit.visit_date else None,
            "scheduled_date": scheduled_date_str,
            "days_until_followup": days_until,
            "followup_status": followup_status,
            "outcome": fu.get("outcome"),
            "suspected_diagnosis": assessment.get("suspected_diagnosis"),
            "medications_dispensed": meds_dispensed,
            "attending_staff": staff.name,
        })

    followups.sort(key=lambda x: x["scheduled_date"])

    overdue = sum(1 for f in followups if f["followup_status"] == "overdue")
    due_today = sum(1 for f in followups if f["followup_status"] == "due_today")
    upcoming = sum(1 for f in followups if f["followup_status"] == "upcoming")

    return APIResponse(
        success=True,
        message="Due follow-ups retrieved",
        data={
            "total": len(followups),
            "overdue": overdue,
            "due_today": due_today,
            "upcoming": upcoming,
            "followups": followups,
        },
    )
