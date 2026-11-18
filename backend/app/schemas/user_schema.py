
from datetime import datetime

from pydantic import BaseModel, EmailStr, Field, ConfigDict


# Data required when a user registers
class UserCreate(BaseModel):
    username: str = Field(min_length=3, max_length=50)

    email: EmailStr

    password: str = Field(min_length=8, max_length=128)


# Data returned after successful registration
class UserResponse(BaseModel):
    id: int
    username: str
    email: EmailStr
    role: str
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


# Data required when a user logs in
class UserLogin(BaseModel):
    email: EmailStr
    password: str


# Response returned after successful login
class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
