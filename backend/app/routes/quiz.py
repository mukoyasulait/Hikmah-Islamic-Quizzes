from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy import select, func
from sqlalchemy.orm import Session, selectinload

from app.database import get_db
from app.models.category import Category
from app.models.question import Question
from app.models.quiz_attempt import QuizAttempt
from app.schemas.quiz_schema import QuizHistoryResponse
from app.models.user_answer import UserAnswer
from app.schemas.quiz_schema import (
    QuizQuestionResponse,
    QuizSubmit,
    QuizResultResponse
)
from app.services.security import get_current_user

router = APIRouter(
    prefix="/quiz",
    tags=["Quiz"]
)


# GET QUESTIONS FOR A LEARNER
@router.get(
    "/questions",
    response_model=list[QuizQuestionResponse]
)
def get_quiz_questions(
    category_id: int = Query(gt=0),
    difficulty: str = Query(
        pattern="^(Beginner|Intermediate|Advanced)$"
    ),
    limit: int = Query(default=10, ge=1, le=50),
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Check that the selected category exists.
    category = db.get(Category, category_id)

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    # Retrieve active questions for the selected category
    # and difficulty level.
    questions = db.scalars(
        select(Question)
        .options(selectinload(Question.options))
        .where(
            Question.category_id == category_id,
            Question.difficulty == difficulty,
            Question.is_active.is_(True)
        )
        .order_by(func.random())
        .limit(limit)
    ).all()

    return questions


# SUBMIT QUIZ AND CALCULATE SCORE
@router.post(
    "/submit",
    response_model=QuizResultResponse
)
def submit_quiz(
    submission: QuizSubmit,
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    # Confirm that the category exists.
    category = db.get(Category, submission.category_id)

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    total_questions = len(submission.answers)

    score = 0
    results = []

    try:
        # Create the quiz attempt.
        attempt = QuizAttempt(
            user_id=current_user.id,
            category_id=submission.category_id,
            total_questions=total_questions,
            status="in_progress"
        )

        db.add(attempt)
        db.flush()

        # Validate and mark each submitted answer.
        for submitted_answer in submission.answers:

            question = db.scalar(
                select(Question)
                .options(selectinload(Question.options))
                .where(
                    Question.id == submitted_answer.question_id,
                    Question.category_id == submission.category_id,
                    Question.difficulty == submission.difficulty,
                    Question.is_active.is_(True)
                )
            )

            if question is None:
                raise HTTPException(
                    status_code=400,
                    detail="Invalid or inactive question submitted"
                )

            selected_option = next(
                (
                    option for option in question.options
                    if option.id == submitted_answer.selected_option_id
                ),
                None
            )

            if selected_option is None:
                raise HTTPException(
                    status_code=400,
                    detail="Selected option does not belong to this question"
                )

            correct_option = next(
                (
                    option for option in question.options
                    if option.is_correct
                ),
                None
            )

            if correct_option is None:
                raise HTTPException(
                    status_code=400,
                    detail="Question has no correct answer configured"
                )

            is_correct = selected_option.is_correct

            if is_correct:
                score += 1

            # Save the learner's answer.
            user_answer = UserAnswer(
                attempt_id=attempt.id,
                question_id=question.id,
                selected_option_id=selected_option.id,
                is_correct=is_correct
            )

            db.add(user_answer)

            # Prepare feedback for the learner.
            results.append({
                "question_id": question.id,
                "question_text": question.question_text,
                "selected_option_id": selected_option.id,
                "correct_option_id": correct_option.id,
                "is_correct": is_correct,
                "explanation": question.explanation,
                "source_reference": question.source_reference
            })

        # Calculate the final percentage.
        percentage = round(
            (score / total_questions) * 100,
            2
        )

        # Complete the attempt.
        attempt.score = score
        attempt.percentage = percentage
        attempt.status = "completed"
        attempt.completed_at = datetime.now(timezone.utc)

        db.commit()
        db.refresh(attempt)

        return {
            "attempt_id": attempt.id,
            "score": score,
            "total_questions": total_questions,
            "percentage": percentage,
            "results": results
        }

    except Exception:
        db.rollback()
        raise


# GET QUIZ HISTORY FOR THE LOGGED-IN LEARNER
@router.get(
    "/history",
    response_model=list[QuizHistoryResponse]
)
def get_quiz_history(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    attempts = db.scalars(
        select(QuizAttempt)
        .where(
            QuizAttempt.user_id == current_user.id,
            QuizAttempt.status == "completed"
        )
        .order_by(QuizAttempt.completed_at.desc())
    ).all()

    return attempts