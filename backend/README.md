# tezoCare — Pharmacy Patient Management System

FastAPI-based backend for managing pharmacy patients, visits, vitals, medications, and push notifications.

## Setup

```bash
# Create virtual environment
python -m venv venv
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt

# Configure environment
cp .env.example .env
# Edit .env with your database URL and secret key

# Apply migrations
alembic upgrade head
```

## Run Dev Server

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

## API Docs

- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

## Migrations

```bash
# Generate a new migration (after model changes)
alembic revision --autogenerate -m "description"

# Apply pending migrations
alembic upgrade head

# Rollback one step
alembic downgrade -1
```

## Environment Variables

| Variable | Description | Default |
|---|---|---|
| `DATABASE_URL` | Async PostgreSQL connection string | `postgresql+asyncpg://user:pass@localhost:5432/tezocare` |
| `SECRET_KEY` | JWT signing secret | — |
| `ALGORITHM` | JWT algorithm | `HS256` |
| `ACCESS_TOKEN_EXPIRE_MINUTES` | Access token TTL | `30` |
| `REFRESH_TOKEN_EXPIRE_DAYS` | Refresh token TTL | `7` |
| `FCM_SERVER_KEY` | Firebase Cloud Messaging server key | — |
| `APP_NAME` | Application name | `tezoCare` |
| `ENVIRONMENT` | Runtime environment | `development` |

## Project Structure

```
app/
├── main.py              # FastAPI entry point, CORS, scheduler lifecycle
├── core/                # Config, database, security
├── api/v1/              # REST endpoints (auth, patients, visits, etc.)
├── models/              # SQLAlchemy ORM models
├── schemas/             # Pydantic v2 request/response schemas
├── services/            # Business logic layer
├── tasks/               # APScheduler background jobs
└── utils/               # Response helpers, pagination
```
