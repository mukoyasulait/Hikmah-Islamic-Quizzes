
from datetime import datetime, timedelta, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.category import Category
from app.models.quiz_attempt import QuizAttempt
from app.models.user import User
from app.schemas.leaderboard_schema import LeaderboardEntry
from app.services.security import get_current_user


router = APIRouter(prefix="/leaderboard", tags=["Leaderboard"])


@router.get("/", response_model=list[LeaderboardEntry])
def get_weekly_leaderboard(
    category_id: int = Query(gt=0),
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    category = db.get(Category, category_id)

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    now = datetime.now(timezone.utc)
    week_start = (
        now - timedelta(days=now.weekday())
    ).replace(hour=0, minute=0, second=0, microsecond=0)

    attempts = db.scalars(
        select(QuizAttempt).where(
            QuizAttempt.category_id == category_id,
            QuizAttempt.status == "completed",
            QuizAttempt.completed_at >= week_start
        )
    ).all()

    best_results = {}

    for attempt in attempts:
        user = db.get(User, attempt.user_id)

        if user is None or user.role != "learner":
            continue

        existing = best_results.get(user.id)

        if (
            existing is None
            or attempt.percentage > existing["percentage"]
            or (
                attempt.percentage == existing["percentage"]
                and attempt.score > existing["score"]
            )
        ):
            best_results[user.id] = {
                "username": user.username,
                "percentage": attempt.percentage,
                "score": attempt.score
            }

    sorted_results = sorted(
        best_results.values(),
        key=lambda item: (
            -item["percentage"],
            -item["score"],
            item["username"].lower()
        )
    )

    return [
        LeaderboardEntry(
            rank=index + 1,
            username=result["username"],
            score_percentage=result["percentage"]
        )
        for index, result in enumerate(sorted_results)
    ]
