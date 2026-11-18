
from pydantic import BaseModel, Field, ConfigDict, model_validator


# One answer option supplied when creating a question
class QuestionOptionCreate(BaseModel):
    option_text: str = Field(min_length=1, max_length=500)
    is_correct: bool = False


# Data required to create a question
class QuestionCreate(BaseModel):
    category_id: int = Field(gt=0)
    question_text: str = Field(min_length=5)
    difficulty: str
    explanation: str = Field(min_length=3)
    source_reference: str | None = None
    options: list[QuestionOptionCreate] = Field(min_length=4, max_length=4)

    @model_validator(mode="after")
    def validate_question(self):
        if self.difficulty not in ["Beginner", "Intermediate", "Advanced"]:
            raise ValueError("Invalid difficulty level")

        if sum(option.is_correct for option in self.options) != 1:
            raise ValueError("Exactly one option must be correct")

        return self


# Data allowed when updating a question
class QuestionUpdate(BaseModel):
    question_text: str | None = Field(default=None, min_length=5)
    difficulty: str | None = None
    explanation: str | None = Field(default=None, min_length=3)
    source_reference: str | None = None
    is_active: bool | None = None


# Option returned to the administrator
class QuestionOptionAdminResponse(BaseModel):
    id: int
    option_text: str
    is_correct: bool

    model_config = ConfigDict(from_attributes=True)


# Full question returned to the administrator
class QuestionAdminResponse(BaseModel):
    id: int
    category_id: int
    question_text: str
    difficulty: str
    explanation: str
    source_reference: str | None
    is_active: bool
    options: list[QuestionOptionAdminResponse]

    model_config = ConfigDict(from_attributes=True)
