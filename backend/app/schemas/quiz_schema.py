from datetime import datetime

from pydantic import BaseModel, Field, ConfigDict, model_validator

# OPTIONS SHOWN TO LEARNERS
class QuizOptionResponse(BaseModel):
    id: int
    option_text: str

    model_config = ConfigDict(from_attributes=True)


# QUESTIONS SHOWN TO LEARNERS
class QuizQuestionResponse(BaseModel):
    id: int
    question_text: str
    difficulty: str
    options: list[QuizOptionResponse]

    model_config = ConfigDict(from_attributes=True)


# ANSWERS SUBMITTED BY LEARNERS
class UserAnswerSubmit(BaseModel):
    question_id: int = Field(gt=0)
    selected_option_id: int = Field(gt=0)


# QUIZ SUBMISSION
class QuizSubmit(BaseModel):
    category_id: int = Field(gt=0)
    difficulty: str
    answers: list[UserAnswerSubmit] = Field(min_length=1)

    @model_validator(mode="after")
    def validate_quiz(self):
        if self.difficulty not in [
            "Beginner", "Intermediate", "Advanced"
        ]:
            raise ValueError("Invalid difficulty level")

        question_ids = [
            answer.question_id for answer in self.answers
        ]

        if len(question_ids) != len(set(question_ids)):
            raise ValueError("Duplicate questions are not allowed")

        return self


# RESULTS FOR EACH ANSWER
class AnswerResult(BaseModel):
    question_id: int
    question_text: str
    selected_option_id: int
    correct_option_id: int
    is_correct: bool
    explanation: str
    source_reference: str | None


# COMPLETE QUIZ RESULT
class QuizResultResponse(BaseModel):
    attempt_id: int
    score: int
    total_questions: int
    percentage: float
    results: list[AnswerResult]


# QUIZ HISTORY FOR LEARNERS
class QuizHistoryResponse(BaseModel):
    id: int
    category_id: int
    score: int
    total_questions: int
    percentage: float
    status: str
    started_at: datetime
    completed_at: datetime | None

    model_config = ConfigDict(from_attributes=True)