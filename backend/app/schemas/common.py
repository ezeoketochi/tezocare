from pydantic import BaseModel


class PaginationMeta(BaseModel):
    page: int
    per_page: int
    total: int
    total_pages: int


class APIResponse(BaseModel):
    success: bool
    message: str
    data: object | None = None
    meta: PaginationMeta | None = None
