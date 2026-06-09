from datetime import datetime, timezone, timedelta, date
from apscheduler.schedulers.asyncio import AsyncIOScheduler
from apscheduler.triggers.cron import CronTrigger
from sqlalchemy import select, and_
from sqlalchemy.ext.asyncio import AsyncSession
import httpx
from app.core.config import settings
from app.core.database import get_session_factory
from app.models.visit import Visit
from app.models.notification import Notification, NotificationType, NotificationStatus
from app.utils.logger import logger

scheduler = AsyncIOScheduler()


async def send_fcm_push(title: str, body: str) -> bool:
    if not settings.FCM_SERVER_KEY:
        return False
    url = "https://fcm.googleapis.com/fcm/send"
    headers = {
        "Authorization": f"key={settings.FCM_SERVER_KEY}",
        "Content-Type": "application/json",
    }
    payload = {
        "to": "/topics/refill_reminders",
        "notification": {"title": title, "body": body},
    }
    async with httpx.AsyncClient() as client:
        response = await client.post(url, json=payload, headers=headers, timeout=15)
        return response.is_success


async def check_refill_needs():
    try:
        logger.info("Running daily refill reminder check")
        tomorrow = date.today() + timedelta(days=1)

        async with get_session_factory()() as db:
            result = await db.execute(
                select(Visit).order_by(Visit.created_at.desc())
            )
            visits = result.scalars().all()
            notifications_created = 0

            for visit in visits:
                meds = visit.medications_dispensed or []
                for med in meds:
                    refill_date_str = med.get("refill_date")
                    drug_name = med.get("drug_name", "")
                    dose = med.get("dose", "")
                    if not refill_date_str or not drug_name:
                        continue
                    try:
                        refill_date = date.fromisoformat(refill_date_str)
                    except (ValueError, TypeError):
                        continue
                    if refill_date != tomorrow:
                        continue

                    logger.info(
                        "Refill due tomorrow for visit %s, drug %s",
                        visit.id, drug_name,
                    )

                    notification = Notification(
                        patient_id=visit.patient_id,
                        type=NotificationType.push,
                        title="Refill Reminder",
                        message=f"Your medication {drug_name} ({dose}) is due for refill tomorrow.",
                        status=NotificationStatus.pending,
                    )
                    db.add(notification)
                    await db.flush()

                    fcm_ok = await send_fcm_push(
                        title="Refill Reminder",
                        body=f"{drug_name} ({dose}) refill due tomorrow.",
                    )
                    if fcm_ok:
                        notification.status = NotificationStatus.sent
                        notification.sent_at = datetime.now(timezone.utc)
                        logger.info("FCM push sent for refill: %s", drug_name)
                    else:
                        notification.status = NotificationStatus.failed
                        logger.warning("FCM push failed for refill: %s", drug_name)

                    notifications_created += 1

            await db.commit()
            logger.info("Daily refill reminder check completed, %d notifications created", notifications_created)
    except Exception:
        logger.exception("Error in daily refill reminder check")


def start_scheduler():
    trigger = CronTrigger(hour=8, minute=0)
    scheduler.add_job(check_refill_needs, trigger=trigger, id="daily_refill_check")
    scheduler.start()
