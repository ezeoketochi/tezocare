from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    APP_NAME: str = "tezoCare"
    VERSION: str = "1.0.0"
    API_V1_STR: str = "/api/v1"
    DATABASE_URL: str = "postgresql+asyncpg://postgres:postgres@localhost:5432/tezocare"
    SECRET_KEY: str = ""
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7
    FIREBASE_CREDENTIALS_PATH: str = ""
    ENVIRONMENT: str = "development"
    CORS_ORIGINS: list[str] = ["*"]
    DB_ECHO: bool = False

    class Config:
        env_file = ".env"


settings = Settings()
