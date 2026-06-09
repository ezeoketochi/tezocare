from fastapi import Query


class PaginationParams:
    def __init__(
        self,
        skip: int = Query(0, ge=0, description="Number of records to skip"),
        limit: int = Query(100, ge=1, le=500, description="Max records per page"),
    ):
        self.skip = skip
        self.limit = limit
