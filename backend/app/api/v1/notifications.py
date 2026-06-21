from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from app.core.config import settings
from app.core.database import get_db
from app.core.security import get_current_user
from app.core.firebase import send_push_notification
from app.models.staff import Staff
from app.schemas.common import APIResponse
from app.core.scheduler import check_due_refills, check_due_followups
from app.utils.logger import logger

router = APIRouter()


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

    if ok:
        logger.info("Test push sent successfully to staff %s", current_staff.id)
        return APIResponse(success=True, message="Test notification sent successfully!")
    else:
        return APIResponse(
            success=False,
            message="Failed to send notification. Check backend logs for details.",
        )
