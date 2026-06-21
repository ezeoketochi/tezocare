import firebase_admin
from firebase_admin import credentials, messaging
from pathlib import Path
from app.core.config import settings
from app.utils.logger import logger

_firebase_app = None


def init_firebase():
    global _firebase_app
    if _firebase_app is not None:
        logger.info("Firebase app already initialized")
        return _firebase_app

    if firebase_admin._apps:
        _firebase_app = list(firebase_admin._apps.values())[0]
        logger.info("Firebase app already initialized (discovered from SDK)")
        return _firebase_app

    cred_path = settings.FIREBASE_CREDENTIALS_PATH
    if not cred_path:
        logger.warning("FIREBASE_CREDENTIALS_PATH not set; firebase not initialized")
        return None

    try:
        base_dir = Path(__file__).resolve().parent.parent.parent
        absolute_cred_path = (base_dir / cred_path).resolve()
        if not absolute_cred_path.exists():
            logger.error("Firebase credentials file not found at %s", absolute_cred_path)
            return None
        cred = credentials.Certificate(str(absolute_cred_path))
        _firebase_app = firebase_admin.initialize_app(cred)
        logger.info("Firebase Admin SDK initialized from %s", absolute_cred_path)
    except Exception:
        logger.exception("Failed to initialize Firebase Admin SDK")
        _firebase_app = None

    return _firebase_app


def send_push_notification(fcm_token: str, title: str, body: str, data: dict | None = None) -> bool:
    if _firebase_app is None:
        logger.warning("Firebase not initialized; skipping push")
        return False

    try:
        message = messaging.Message(
            token=fcm_token,
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in (data or {}).items()},
        )
        response = messaging.send(message)
        logger.info("FCM push sent, message_id=%s", response)
        return True
    except Exception:
        logger.exception("FCM push failed for token %s", fcm_token[:10])
        return False
