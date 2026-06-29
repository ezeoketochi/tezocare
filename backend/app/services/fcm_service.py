from datetime import date
from sqlalchemy import Date, select, and_
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.firebase import send_push_notification
from app.models.staff import Staff
from app.models.notification_log import NotificationLog, NotificationLogType
from app.models.staff_notification import StaffNotificationStatus
from app.services.staff_notification_service import StaffNotificationService
from app.utils.logger import logger


async def send_staff_notification(
    db: AsyncSession,
    staff_id,
    patient_id,
    ntype: NotificationLogType,
    reference_id: str,
    days_before: int,
    title: str,
    body: str,
    data: dict | None = None,
) -> bool:
    result = await db.execute(select(Staff).where(Staff.id == staff_id))
    staff = result.scalar_one_or_none()
    if not staff or not staff.fcm_token:
        logger.warning("No FCM token for staff %s", staff_id)
        return False

    existing = await db.execute(
        select(NotificationLog).where(
            NotificationLog.staff_id == staff_id,
            NotificationLog.patient_id == patient_id,
            NotificationLog.type == ntype,
            NotificationLog.reference_id == reference_id,
            NotificationLog.days_before == days_before,
            NotificationLog.sent_at.cast(Date) == date.today(),
        )
    )
    if existing.scalar_one_or_none():
        logger.info("Notification already sent today for staff=%s type=%s ref=%s days=%d", staff_id, ntype.value, reference_id, days_before)
        return True

    ok = send_push_notification(staff.fcm_token, title, body, data)

    log = NotificationLog(
        staff_id=staff_id,
        patient_id=patient_id,
        type=ntype,
        reference_id=reference_id,
        days_before=days_before,
    )
    db.add(log)

    status = StaffNotificationStatus.sent if ok else StaffNotificationStatus.failed
    await StaffNotificationService.create(
        db=db,
        staff_id=str(staff_id),
        patient_id=str(patient_id) if patient_id else None,
        type=ntype.value,
        title=title,
        message=body,
        status=status,
    )

    if ok:
        logger.info("Notification sent to staff %s: %s", staff_id, title)
    else:
        logger.warning("Notification failed for staff %s: %s", staff_id, title)

    return ok


async def send_due_refill_notification(
    db: AsyncSession,
    staff_id,
    patient_id,
    refill_id: str,
    patient_name: str,
    drug_name: str,
    days_until_refill: int,
) -> bool:
    day_label = "today" if days_until_refill == 0 else f"in {days_until_refill} day(s)"
    return await send_staff_notification(
        db=db,
        staff_id=staff_id,
        patient_id=patient_id,
        ntype=NotificationLogType.refill,
        reference_id=str(refill_id),
        days_before=days_until_refill,
        title="Refill Due Soon",
        body=f"{patient_name}'s {drug_name} refill is due {day_label}",
        data={"type": "refill", "patient_id": str(patient_id), "visit_id": ""},
    )


async def send_due_followup_notification(
    db: AsyncSession,
    staff_id,
    patient_id,
    visit_id: str,
    patient_name: str,
    days_until_followup: int,
    scheduled_date: str,
) -> bool:
    day_label = "today" if days_until_followup == 0 else f"in {days_until_followup} day(s)"
    return await send_staff_notification(
        db=db,
        staff_id=staff_id,
        patient_id=patient_id,
        ntype=NotificationLogType.followup,
        reference_id=str(visit_id),
        days_before=days_until_followup,
        title="Follow-up Due Soon",
        body=f"{patient_name}'s follow-up is scheduled {day_label} on {scheduled_date}",
        data={"type": "followup", "patient_id": str(patient_id), "visit_id": str(visit_id)},
    )
