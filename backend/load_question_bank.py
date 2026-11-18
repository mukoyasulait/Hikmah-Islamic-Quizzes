"""
Hikmah Islamic Quizzes — safe question-bank loader.

Save as backend/load_question_bank.py.
Expected data: backend/question_bank.json

Run from the project root:
    .\\backend\\.venv\\Scripts\\python.exe .\\backend\\load_question_bank.py
"""
import json
import sys
from pathlib import Path

from sqlalchemy import select

BACKEND_DIR = Path(__file__).resolve().parent
if str(BACKEND_DIR) not in sys.path:
    sys.path.insert(0, str(BACKEND_DIR))

from app.database import SessionLocal
from app.models.category import Category
from app.models.question import Question
from app.models.question_option import QuestionOption

EXPECTED_CATEGORIES = {
    "Ulum al-Quran", "Hadith Studies", "Fiqh",
    "Aqeedah", "Islamic History", "Akhlaq",
}
DIFFICULTIES = {"Beginner", "Intermediate", "Advanced"}
EXPECTED_PER_GROUP = 20
EXPECTED_TOTAL = 360


def validate_bank(items):
    if not isinstance(items, list) or len(items) != EXPECTED_TOTAL:
        raise ValueError(f"Expected a JSON list containing exactly {EXPECTED_TOTAL} questions.")

    counts = {(category, level): 0
              for category in EXPECTED_CATEGORIES
              for level in DIFFICULTIES}
    seen = set()
    required = {
        "category", "difficulty", "question_text",
        "explanation", "source_reference", "options"
    }

    for number, item in enumerate(items, 1):
        if not isinstance(item, dict):
            raise ValueError(f"Question #{number} must be an object.")
        missing = required - item.keys()
        if missing:
            raise ValueError(f"Question #{number} is missing fields: {sorted(missing)}")

        category, level = item["category"], item["difficulty"]
        if category not in EXPECTED_CATEGORIES:
            raise ValueError(f"Question #{number}: unknown category {category!r}.")
        if level not in DIFFICULTIES:
            raise ValueError(f"Question #{number}: invalid difficulty {level!r}.")

        text = item["question_text"]
        explanation = item["explanation"]
        source = item["source_reference"]
        if not isinstance(text, str) or len(text.strip()) < 5:
            raise ValueError(f"Question #{number}: question text is too short.")
        if not isinstance(explanation, str) or len(explanation.strip()) < 3:
            raise ValueError(f"Question #{number}: explanation is too short.")
        if not isinstance(source, str) or not source.strip():
            raise ValueError(f"Question #{number}: source reference is required.")

        identity = (category, level, text.strip().casefold())
        if identity in seen:
            raise ValueError(f"Duplicate question: {text}")
        seen.add(identity)

        options = item["options"]
        if not isinstance(options, list) or len(options) != 4:
            raise ValueError(f"Question #{number}: exactly four options are required.")
        for option in options:
            if (not isinstance(option, dict)
                    or not isinstance(option.get("option_text"), str)
                    or not option["option_text"].strip()
                    or not isinstance(option.get("is_correct"), bool)):
                raise ValueError(f"Question #{number}: invalid option structure.")
        if sum(option["is_correct"] for option in options) != 1:
            raise ValueError(f"Question #{number}: exactly one option must be correct.")

        counts[(category, level)] += 1

    wrong = {f"{category} / {level}": count
             for (category, level), count in counts.items()
             if count != EXPECTED_PER_GROUP}
    if wrong:
        raise ValueError(f"Every category/difficulty group needs 20 questions. Found: {wrong}")


def main():
    bank_file = BACKEND_DIR / "question_bank.json"
    if not bank_file.exists():
        raise FileNotFoundError(f"Place question_bank.json here: {bank_file}")

    with bank_file.open("r", encoding="utf-8") as file:
        items = json.load(file)

    # Validate the entire bank before making any database changes.
    validate_bank(items)

    db = SessionLocal()
    inserted = skipped = 0
    try:
        categories = db.scalars(select(Category)).all()
        category_ids = {category.name: category.id for category in categories}
        missing = EXPECTED_CATEGORIES - category_ids.keys()
        if missing:
            raise ValueError(f"Missing database categories: {sorted(missing)}")

        existing_rows = db.scalars(select(Question)).all()
        existing = {
            (q.category_id, q.difficulty, q.question_text.strip().casefold())
            for q in existing_rows
        }

        for item in items:
            category_id = category_ids[item["category"]]
            identity = (
                category_id,
                item["difficulty"],
                item["question_text"].strip().casefold(),
            )
            if identity in existing:
                skipped += 1
                continue

            question = Question(
                category_id=category_id,
                question_text=item["question_text"].strip(),
                difficulty=item["difficulty"],
                explanation=item["explanation"].strip(),
                source_reference=item["source_reference"].strip(),
                is_active=True,
                options=[
                    QuestionOption(
                        option_text=option["option_text"].strip(),
                        is_correct=option["is_correct"],
                    )
                    for option in item["options"]
                ],
            )
            db.add(question)
            existing.add(identity)
            inserted += 1

        db.commit()
        print("Question-bank import completed.")
        print(f"Inserted: {inserted}")
        print(f"Skipped as existing: {skipped}")
        print(f"Records in supplied bank: {len(items)}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    try:
        main()
    except Exception as error:
        print(f"IMPORT STOPPED: {error}")
        print("The transaction was rolled back; no partial import was committed.")
        raise SystemExit(1)
