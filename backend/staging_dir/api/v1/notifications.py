from fastapi import APIRouter, Depends
from app.core.config import settings
from app.core.security import get_current_user
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
