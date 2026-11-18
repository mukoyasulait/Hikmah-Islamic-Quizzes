
from sqlalchemy import ForeignKey, Boolean
from sqlalchemy.orm import Mapped, mapped_column

from app.database import Base


class UserAnswer(Base):
    __tablename__ = "user_answers"

    id: Mapped[int] = mapped_column(
        primary_key=True,
        index=True
    )

    attempt_id: Mapped[int] = mapped_column(
        ForeignKey("quiz_attempts.id"),
        nullable=False
    )

    question_id: Mapped[int] = mapped_column(
        ForeignKey("questions.id"),
        nullable=False
    )

    selected_option_id: Mapped[int] = mapped_column(
        ForeignKey("question_options.id"),
        nullable=False
    )

    is_correct: Mapped[bool] = mapped_column(
        Boolean,
        default=False,
        nullable=False
    )
