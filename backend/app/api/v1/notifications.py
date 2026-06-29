from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
from app.core.database import get_db
from app.core.security import get_current_user
from app.core.firebase import send_push_notification
from app.models.staff import Staff
from app.schemas.common import APIResponse
from app.schemas.notification import StaffNotificationResponse
from app.services.staff_notification_service import StaffNotificationService
from app.core.scheduler import check_due_refills, check_due_followups
from app.utils.logger import logger

router = APIRouter()


@router.get("", response_model=APIResponse)
async def get_notifications(
    skip: int = Query(0, ge=0),
    limit: int = Query(50, ge=1, le=100),
    current_staff: Staff = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    notifications = await StaffNotificationService.list_for_staff(
        db=db,
        staff_id=str(current_staff.id),
        skip=skip,
        limit=limit,
    )
    unread_count = await StaffNotificationService.get_unread_count(
        db=db,
        staff_id=str(current_staff.id),
    )
    return APIResponse(
        success=True,
        message="Notifications retrieved successfully",
        data={
            "notifications": [
                _to_response(n) for n in notifications
            ],
            "unread_count": unread_count,
        },
    )


@router.patch("/{notification_id}/read", response_model=APIResponse)
async def mark_notification_read(
    notification_id: str,
    current_staff: Staff = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    notification = await StaffNotificationService.mark_read(
        db=db,
        notification_id=notification_id,
        staff_id=str(current_staff.id),
    )
    if not notification:
        return APIResponse(
            success=False,
            message="Notification not found",
        )
    return APIResponse(
        success=True,
        message="Notification marked as read",
    )


@router.post("/test")
async def test_notifications(current_staff: Staff = Depends(get_current_user)):
    if settings.ENVIRONMENT == "production":
        return APIResponse(
            success=False,
            message="Test endpoint not available in production",
        )

    logger.info("Manual notification trigger by staff %s", current_staff.id)
    await check_due_refills()
    await check_due_followups()

    return APIResponse(
        success=True,
        message="Notification jobs triggered manually",
    )


@router.post("/test/send")
async def test_send_notification(
    current_staff: Staff = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if settings.ENVIRONMENT == "production":
        return APIResponse(
            success=False,
            message="Test endpoint not available in production",
        )

    if not current_staff.fcm_token:
        return APIResponse(
            success=False,
            message="You have no FCM token. Log in on your Flutter app first so it uploads its token.",
        )

    ok = send_push_notification(
        fcm_token=current_staff.fcm_token,
        title="Test Notification",
        body=f"Hello {current_staff.name}, this is a direct test push from tezoCare backend.",
        data={"type": "test", "staff_id": str(current_staff.id)},
    )

    status = "sent" if ok else "failed"
    await StaffNotificationService.create(
        db=db,
        staff_id=str(current_staff.id),
        type="test",
        title="Test Notification",
        message=f"Hello {current_staff.name}, this is a direct test push from tezoCare backend.",
        status=status,
    )

    if ok:
        logger.info("Test push sent successfully to staff %s", current_staff.id)
        return APIResponse(success=True, message="Test notification sent successfully!")
    else:
        return APIResponse(
            success=False,
            message="Failed to send notification. Check backend logs for details.",
        )


def _to_response(notification) -> dict:
    return {
        "id": str(notification.id),
        "type": notification.type,
        "title": notification.title,
        "message": notification.message,
        "status": notification.status.value if hasattr(notification.status, 'value') else notification.status,
        "patient_id": str(notification.patient_id) if notification.patient_id else None,
        "patient_name": None,
        "created_at": notification.created_at.isoformat(),
        "read_at": notification.read_at.isoformat() if notification.read_at else None,
    }
