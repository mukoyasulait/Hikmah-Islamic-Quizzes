
from datetime import datetime, timezone

from sqlalchemy import (
    Integer,
    ForeignKey,
    DateTime,
    String,
    Float
)
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class QuizAttempt(Base):
    __tablename__ = "quiz_attempts"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True
    )

    user_id: Mapped[int] = mapped_column(
        ForeignKey("users.id"),
        nullable=False
    )

    category_id: Mapped[int] = mapped_column(
        ForeignKey("categories.id"),
        nullable=False
    )

    score: Mapped[int] = mapped_column(
        Integer,
        default=0,
        nullable=False
    )

    total_questions: Mapped[int] = mapped_column(
        Integer,
        nullable=False
    )

    percentage: Mapped[float] = mapped_column(
        Float,
        default=0.0,
        nullable=False
    )

    status: Mapped[str] = mapped_column(
        String(20),
        default="in_progress",
        nullable=False
    )

    started_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=lambda: datetime.now(timezone.utc)
    )

    completed_at: Mapped[datetime | None] = mapped_column(
        DateTime(timezone=True),
        nullable=True
    )
