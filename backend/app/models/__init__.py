
""" What does this do? It imports all six database models 
into one central location. This makes it easier for
SQLAlchemy to discover the tables."""


from app.models.user import User
from app.models.category import Category
from app.models.question import Question
from app.models.question_option import QuestionOption
from app.models.quiz_attempt import QuizAttempt
from app.models.user_answer import UserAnswer

__all__ = [
    "User",
    "Category",
    "Question",
    "QuestionOption",
    "QuizAttempt",
    "UserAnswer",
]
