
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy import select
from sqlalchemy.exc import IntegrityError
from sqlalchemy.orm import Session

from app.database import get_db
from app.models.category import Category
from app.models.question import Question
from app.schemas.category_schema import (
    CategoryCreate,
    CategoryUpdate,
    CategoryResponse
)
from app.services.security import get_current_user, require_admin


router = APIRouter(
    prefix="/categories",
    tags=["Categories"]
)


# VIEW ALL CATEGORIES
@router.get(
    "/",
    response_model=list[CategoryResponse]
)
def get_categories(
    current_user=Depends(get_current_user),
    db: Session = Depends(get_db)
):
    categories = db.scalars(
        select(Category).order_by(Category.id)
    ).all()

    return categories


# CREATE A CATEGORY (ADMIN ONLY)
@router.post(
    "/",
    response_model=CategoryResponse,
    status_code=status.HTTP_201_CREATED
)
def create_category(
    category_data: CategoryCreate,
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    existing_category = db.scalar(
        select(Category).where(
            Category.name == category_data.name
        )
    )

    if existing_category:
        raise HTTPException(
            status_code=400,
            detail="Category already exists"
        )

    new_category = Category(
        name=category_data.name,
        description=category_data.description
    )

    try:
        db.add(new_category)
        db.commit()
        db.refresh(new_category)

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Category already exists"
        )

    return new_category


# UPDATE A CATEGORY (ADMIN ONLY)
@router.put(
    "/{category_id}",
    response_model=CategoryResponse
)
def update_category(
    category_id: int,
    category_data: CategoryUpdate,
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    category = db.get(Category, category_id)

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    updates = category_data.model_dump(exclude_unset=True)

    if not updates:
        raise HTTPException(
            status_code=400,
            detail="No update information provided"
        )

    for field, value in updates.items():
        if field == "name" and value is None:
            raise HTTPException(
                status_code=400,
                detail="Category name cannot be empty"
            )

        setattr(category, field, value)

    try:
        db.commit()
        db.refresh(category)

    except IntegrityError:
        db.rollback()
        raise HTTPException(
            status_code=400,
            detail="Another category already uses that name"
        )

    return category


# DELETE A CATEGORY (ADMIN ONLY)
@router.delete(
    "/{category_id}"
)
def delete_category(
    category_id: int,
    current_user=Depends(require_admin),
    db: Session = Depends(get_db)
):
    category = db.get(Category, category_id)

    if category is None:
        raise HTTPException(
            status_code=404,
            detail="Category not found"
        )

    # Prevent deleting categories that contain questions.
    existing_questions = db.scalar(
        select(Question.id).where(
            Question.category_id == category_id
        ).limit(1)
    )

    if existing_questions is not None:
        raise HTTPException(
            status_code=400,
            detail="Cannot delete a category that contains questions"
        )

    db.delete(category)
    db.commit()

    return {
        "message": "Category deleted successfully"
    }
