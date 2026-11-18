
from fastapi import FastAPI

from app.database import Base, engine
from app import models
from app.routes.auth import router as auth_router
from app.routes.category import router as category_router
from app.routes.question import router as question_router
from app.routes.quiz import router as quiz_router
from app.routes.leaderboard import router as leaderboard_router


# Create database tables
Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="Hikmah Islamic Quizzes API",
    description="Backend API for the Hikmah Islamic Quizzes mobile application.",
    version="1.0.0"
)
app.include_router(auth_router)
app.include_router(category_router)
app.include_router(question_router)
app.include_router(quiz_router)
app.include_router(leaderboard_router)

@app.get("/")
def home():
    return {
        "message": "Welcome to Hikmah Islamic Quizzes API",
        "status": "running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy",
        "application": "Hikmah Islamic Quizzes"
    }


@app.get("/database-status")
def database_status():
    return {
        "database": "SQLite",
        "status": "connected",
        "tables_created": True
    }
