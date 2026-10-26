import json
from contextlib import asynccontextmanager
from fastapi import FastAPI, Request, UploadFile , File
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from starlette.types import ASGIApp, Receive, Scope, Send

from app.core.config import settings
from app.core.firebase import init_firebase
from app.api.v1 import api_router
from app.tasks.reminder_tasks import start_scheduler as start_reminder_scheduler, scheduler as reminder_scheduler
from app.core.scheduler import start_scheduler as start_notification_scheduler, scheduler as notification_scheduler
from app.utils.logger import logger
from mangum import Mangum
from fastapi.staticfiles import StaticFiles
import shutil
import os

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("Starting tezoCare application")
    
    # ─── 1. INITIALIZE FIREBASE ADMIN SDK ───
    init_firebase()

    # ─── 2. START CRON SCHEDULERS ───
    start_reminder_scheduler()
    start_notification_scheduler()
    
    yield
    
    # ─── 3. CLEAN UP RESOURCES ON SHUTDOWN ───
    if reminder_scheduler.running:
        reminder_scheduler.shutdown()
    if notification_scheduler.running:
        notification_scheduler.shutdown()
    logger.info("Shutting down tezoCare application")


app = FastAPI(
    title=settings.APP_NAME,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    lifespan=lifespan,
    redirect_slashes=True
)
handler = Mangum(app)
UPLOAD_DIR = "/app/uploads"

# 1. Mount the folder so it is publicly accessible at the "/public" URL path
os.makedirs(UPLOAD_DIR, exist_ok=True)
app.mount("/public", StaticFiles(directory=UPLOAD_DIR), name="uploads")

@app.post("/upload/")
async def upload_image(request: Request, file: UploadFile = File(...)):
    file_path = os.path.join(UPLOAD_DIR, file.filename)
    
    with open(file_path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)
        
    # 2. Dynamically build the absolute URL to the file
    base_url = str(request.base_url) # e.g., "http://localhost:8000/"
    file_url = f"{base_url}public/{file.filename}"
        
    return {
        "filename": file.filename, 
        "status": "Uploaded successfully!",
        "url": file_url  # Returns the clickable URL
    }


app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.exception_handler(RequestValidationError)
async def validation_exception_handler(
    request: Request,
    exc: RequestValidationError,
):
    errors = []
    for error in exc.errors():
        field = error.get("loc", [])
        field_name = field[-1] if field else "field"
        message = error.get("msg", "Invalid value")
        message = message.replace("Value error, ", "")
        message = message.replace(
            "value is not a valid email address: ",
            "",
        )
        message = message.replace(
            "The email address is not valid. It must have exactly one @-sign.",
            "Please enter a valid email address",
        )
        message = message.replace(
            "An email address must have an @-sign.",
            "Please enter a valid email address",
        )
        errors.append({
            "field": field_name,
            "message": message,
        })
    return JSONResponse(
        status_code=422,
        content={
            "success": False,
            "message": "Validation failed",
            "errors": errors,
            "code": "VALIDATION_ERROR",
        },
    )


@app.exception_handler(Exception)
async def global_exception_handler(request: Request, exc: Exception):
    logger.exception("Unhandled exception on %s %s", request.method, request.url.path)
    # The generic Exception handler runs outside CORSMiddleware, so its response
    # would otherwise reach the browser without CORS headers and be reported as a
    # cross-origin/security failure, masking the real 500.
    headers = {}
    origin = request.headers.get("origin")
    if origin:
        headers["Access-Control-Allow-Origin"] = origin
        headers["Access-Control-Allow-Credentials"] = "true"
        headers["Vary"] = "Origin"
    return JSONResponse(
        status_code=500,
        content={
            "success": False,
            "message": "Internal server error",
            "data": None,
        },
        headers=headers,
    )


class ResponseLoggingMiddleware:
    def __init__(self, app: ASGIApp):
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send):
        if scope["type"] != "http":
            await self.app(scope, receive, send)
            return

        body_parts = []
        status_code = None

        async def send_wrapper(message):
            nonlocal status_code
            if message["type"] == "http.response.start":
                status_code = message["status"]
            elif message["type"] == "http.response.body":
                body_parts.append(message.get("body", b""))
            await send(message)

        await self.app(scope, receive, send_wrapper)

        body = b"".join(body_parts)
        try:
            body_preview = json.dumps(json.loads(body), indent=2)
        except Exception:
            body_preview = body.decode("utf-8", errors="replace")[:500]
        logger.info(
            "RESPONSE: %s %s -> %d\n%s",
            scope["method"],
            scope["path"],
            status_code,
            body_preview,
        )


app.add_middleware(ResponseLoggingMiddleware)

app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/")
def root():
    return {"name": settings.APP_NAME, "version": settings.VERSION}