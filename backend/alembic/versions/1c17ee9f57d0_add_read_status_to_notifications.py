"""add_read_status_to_notifications

Revision ID: 1c17ee9f57d0
Revises: 6c2207a9e1ca
Create Date: 2026-06-29 23:01:38.012117

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa


# revision identifiers, used by Alembic.
revision: str = '1c17ee9f57d0'
down_revision: Union[str, Sequence[str], None] = '6c2207a9e1ca'
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    op.execute("ALTER TYPE staffnotificationstatus ADD VALUE 'read'")


def downgrade() -> None:
    # Create a new enum without 'read', alter the column, drop the old one
    op.execute("ALTER TYPE staffnotificationstatus RENAME TO staffnotificationstatus_old")
    op.execute("CREATE TYPE staffnotificationstatus AS ENUM('sent', 'pending', 'failed')")
    op.execute(
        "ALTER TABLE staff_notifications "
        "ALTER COLUMN status TYPE staffnotificationstatus "
        "USING status::text::staffnotificationstatus"
    )
    op.execute("DROP TYPE staffnotificationstatus_old")
