import json
from collections import Counter
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent
BATCH_DIR = BASE_DIR / "question_batches"
OUTPUT_FILE = BASE_DIR / "question_bank.json"

EXPECTED = {
    "ulum_al_quran_60.json": "Ulum al-Quran",
    "hadith_studies_60.json": "Hadith Studies",
    "fiqh_60.json": "Fiqh",
    "aqeedah_60.json": "Aqeedah",
    "islamic_history_60.json": "Islamic History",
    "akhlaq_60.json": "Akhlaq",
}
DIFFICULTIES = ("Beginner", "Intermediate", "Advanced")


def fail(message):
    raise SystemExit(f"\nVALIDATION FAILED: {message}")


def main():
    all_questions = []
    category_counts = Counter()
    level_counts = Counter()
    seen = set()

    if not BATCH_DIR.is_dir():
        fail(f"Folder not found: {BATCH_DIR}")

    for filename, expected_category in EXPECTED.items():
        path = BATCH_DIR / filename
        if not path.is_file():
            fail(f"Missing batch file: {path}")

        try:
            with path.open("r", encoding="utf-8") as file:
                batch = json.load(file)
        except json.JSONDecodeError as error:
            fail(f"{filename} contains invalid JSON: {error}")

        if not isinstance(batch, list):
            fail(f"{filename} must contain a JSON list.")
        if len(batch) != 60:
            fail(f"{filename} contains {len(batch)} records; expected 60.")

        file_levels = Counter()
        for index, question in enumerate(batch, start=1):
            label = f"{filename}, question {index}"

            if not isinstance(question, dict):
                fail(f"{label} is not a JSON object.")
            if question.get("category") != expected_category:
                fail(f"{label} has category {question.get('category')!r}; expected {expected_category!r}.")
            if question.get("difficulty") not in DIFFICULTIES:
                fail(f"{label} has an unsupported difficulty.")
            if not isinstance(question.get("question_text"), str) or len(question["question_text"].strip()) < 5:
                fail(f"{label} has missing/short question_text.")
            if not isinstance(question.get("explanation"), str) or len(question["explanation"].strip()) < 3:
                fail(f"{label} has missing/short explanation.")
            if not isinstance(question.get("source_reference"), str) or not question["source_reference"].strip():
                fail(f"{label} has a missing source_reference.")

            options = question.get("options")
            if not isinstance(options, list) or len(options) != 4:
                fail(f"{label} must have exactly four options.")

            correct_count = 0
            for option_number, option in enumerate(options, start=1):
                if not isinstance(option, dict):
                    fail(f"{label}, option {option_number} is not an object.")
                if not isinstance(option.get("option_text"), str) or not option["option_text"].strip():
                    fail(f"{label}, option {option_number} has missing option_text.")
                if not isinstance(option.get("is_correct"), bool):
                    fail(f"{label}, option {option_number} is_correct must be true or false.")
                correct_count += option["is_correct"]

            if correct_count != 1:
                fail(f"{label} must have exactly one correct option.")

            key = (expected_category.casefold(), question["difficulty"], question["question_text"].strip().casefold())
            if key in seen:
                fail(f"Duplicate question text found in {label}.")
            seen.add(key)

            file_levels[question["difficulty"]] += 1
            category_counts[expected_category] += 1
            level_counts[(expected_category, question["difficulty"])] += 1
            all_questions.append(question)

        for difficulty in DIFFICULTIES:
            if file_levels[difficulty] != 20:
                fail(f"{filename} has {file_levels[difficulty]} {difficulty} questions; expected 20.")

        print(f"Validated {filename}: 60 questions (20 per difficulty).")

    if len(all_questions) != 360:
        fail(f"Combined total is {len(all_questions)}; expected 360.")

    for category in EXPECTED.values():
        if category_counts[category] != 60:
            fail(f"{category} has {category_counts[category]} questions; expected 60.")
        for difficulty in DIFFICULTIES:
            count = level_counts[(category, difficulty)]
            if count != 20:
                fail(f"{category} / {difficulty} has {count} questions; expected 20.")

    with OUTPUT_FILE.open("w", encoding="utf-8") as file:
        json.dump(all_questions, file, ensure_ascii=False, indent=2)

    print("\nSUCCESS: All six batches passed validation.")
    print(f"Total questions: {len(all_questions)}")
    print(f"Output created: {OUTPUT_FILE}")
    print("The original batch files have not been changed or deleted.")


if __name__ == "__main__":
    main()
