
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session, selectinload

from app.database import get_db
from app.models.category import Category
from app.models.question import Question
from app.models.question_option import QuestionOption
from app.schemas.question_schema import (
    QuestionCreate,
    QuestionUpdate,
    QuestionAdminResponse
)
from app.services.security import require_admin


router = APIRouter(
    prefix="/questions",
    tags=["Questions"]
)


# CREATE A QUESTION (ADMIN ONLY)
@router.post(
    "/",
    response_model=QuestionAdminResponse,
    status_code=status.HTTP_201_CREATED
)
def create_question(
    question_data: QuestionCreate,
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    # Confirm that the category exists.
    category = db.get(Category, question_data.category_id)

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    new_question = Question(
        category_id=question_data.category_id,
        question_text=question_data.question_text,
        difficulty=question_data.difficulty,
        explanation=question_data.explanation,
        source_reference=question_data.source_reference
    )

    try:
        db.add(new_question)
        db.flush()

        for option_data in question_data.options:
            new_option = QuestionOption(
                question_id=new_question.id,
                option_text=option_data.option_text,
                is_correct=option_data.is_correct
            )
            db.add(new_option)

        db.commit()

        question = db.scalar(
            select(Question)
            .options(selectinload(Question.options))
            .where(Question.id == new_question.id)
        )

        return question

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Unable to save question"
        )


# VIEW ALL QUESTIONS (ADMIN ONLY)
@router.get(
    "/admin",
    response_model=list[QuestionAdminResponse]
)
def get_all_questions(
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    questions = db.scalars(
        select(Question)
        .options(selectinload(Question.options))
        .order_by(Question.id)
    ).all()

    return questions


# UPDATE A QUESTION (ADMIN ONLY)
@router.put(
    "/{question_id}",
    response_model=QuestionAdminResponse
)
def update_question(
    question_id: int,
    question_data: QuestionUpdate,
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    question = db.scalar(
        select(Question)
        .options(selectinload(Question.options))
        .where(Question.id == question_id)
    )

    if question is None:
        raise HTTPException(
            status_code=404,
            detail="Question not found"
        )

    updates = question_data.model_dump(exclude_unset=True)

    if "difficulty" in updates:
        if updates["difficulty"] not in [
            "Beginner", "Intermediate", "Advanced"
        ]:
            raise HTTPException(
                status_code=400,
                detail="Invalid difficulty level"
            )

    for field, value in updates.items():
        setattr(question, field, value)

    db.commit()
    db.refresh(question)

    return question


# DEACTIVATE A QUESTION (ADMIN ONLY)
@router.delete("/{question_id}")
def deactivate_question(
    question_id: int,
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    question = db.get(Question, question_id)

    if question is None:
        raise HTTPException(
            status_code=404,
            detail="Question not found"
        )

    # Preserve historical quiz records.
    question.is_active = False

    db.commit()

    return {
        "message": "Question deactivated successfully"
    }
