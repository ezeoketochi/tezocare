from datetime import datetime, timedelta, date
from zoneinfo import ZoneInfo
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy import select
from app.core.database import get_session_factory
from app.core.firebase import init_firebase
from app.models.refill import Refill
from app.models.visit import Visit, VisitStatus
from app.models.patient import Patient
from app.services.fcm_service import (
    send_due_refill_notification,
    send_due_followup_notification,
)
from app.utils.logger import logger

TZ = ZoneInfo("Africa/Lagos")
scheduler = AsyncIOScheduler()


async def check_due_refills():
    try:
        logger.info("Running due refills notification check")
        today = datetime.now(TZ).date()
        targets = [today + timedelta(days=d) for d in (3, 1, 0)]

        async with get_session_factory()() as db:
            result = await db.execute(
                select(Refill, Visit, Patient)
                .join(Visit, Refill.visit_id == Visit.id)
                .join(Patient, Refill.patient_id == Patient.id)
                .where(Refill.refill_date.in_(targets))
            )
            rows = result.all()
            sent = 0
            for refill, visit, patient in rows:
                days = (refill.refill_date - today).days
                ok = await send_due_refill_notification(
                    db=db,
                    staff_id=visit.staff_id,
                    patient_id=patient.id,
                    refill_id=str(refill.id),
                    patient_name=f"{patient.first_name} {patient.last_name}",
                    drug_name=refill.drug_name,
                    days_until_refill=days,
                )
                if ok:
                    sent += 1
            logger.info("Due refills check complete, %d notifications sent", sent)
    except Exception:
        logger.exception("Error in check_due_refills")



async def check_due_followups():
    try:
        logger.info("Running due follow-ups notification check")
        today = datetime.now(TZ).date()
        targets = [today + timedelta(days=d) for d in (3, 1, 0)]

        async with get_session_factory()() as db:
            result = await db.execute(
                select(Visit, Patient)
                .join(Patient, Visit.patient_id == Patient.id)
                .where(Visit.status.in_([VisitStatus.follow_up_pending, VisitStatus.active]))
            )
            rows = result.all()
            sent = 0
            for visit, patient in rows:
                fu = visit.follow_up or {}
                if fu.get("is_done", False):
                    continue
                sched = fu.get("scheduled_date")
                if not sched:
                    continue
                try:
                    scheduled = date.fromisoformat(sched) if isinstance(sched, str) else sched
                except (ValueError, TypeError):
                    continue
                if scheduled not in targets:
                    continue
                days = (scheduled - today).days
                ok = await send_due_followup_notification(
                    db=db,
                    staff_id=visit.staff_id,
                    patient_id=patient.id,
                    visit_id=str(visit.id),
                    patient_name=f"{patient.first_name} {patient.last_name}",
                    days_until_followup=days,
                    scheduled_date=scheduled.isoformat(),
                )
                if ok:
                    sent += 1
            logger.info("Due follow-ups check complete, %d notifications sent", sent)
    except Exception:
        logger.exception("Error in check_due_followups")



def start_scheduler():
    init_firebase()
    trigger = CronTrigger(hour=8, minute=0, timezone=TZ)
    scheduler.add_job(check_due_refills, trigger=trigger, id="daily_due_refills")
    scheduler.add_job(check_due_followups, trigger=trigger, id="daily_due_followups")
    scheduler.start()
    logger.info("Notification scheduler started with daily jobs at 08:00 Africa/Lagos")
