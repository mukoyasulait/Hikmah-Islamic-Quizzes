
import sqlite3
from pathlib import Path

# Always connect to the database inside the backend folder
BASE_DIR = Path(__file__).resolve().parent
DATABASE_PATH = BASE_DIR / "hikmah.db"

connection = sqlite3.connect(DATABASE_PATH)
cursor = connection.cursor()

print("HIKMAH ISLAMIC QUIZZES DATABASE")
print("=" * 45)
print(f"Database: {DATABASE_PATH}")

# Display all database tables
cursor.execute("""
    SELECT name
    FROM sqlite_master
    WHERE type = 'table'
    ORDER BY name
""")

tables = cursor.fetchall()

print("\nDATABASE TABLES")

for table in tables:
    print("-", table[0])

# Display question count
cursor.execute("SELECT COUNT(*) FROM questions")
question_count = cursor.fetchone()[0]

print(f"\nTOTAL QUESTIONS: {question_count}")

# Display questions grouped by category and difficulty
cursor.execute("""
    SELECT categories.name, questions.difficulty, COUNT(*)
    FROM questions
    JOIN categories ON questions.category_id = categories.id
    GROUP BY categories.name, questions.difficulty
    ORDER BY categories.id, questions.difficulty
""")

print("\nQUESTIONS PER CATEGORY AND DIFFICULTY")

for category, difficulty, count in cursor.fetchall():
    print(f"{category} | {difficulty}: {count}")

connection.close()
