
from fastapi import FastAPI

from app.database import Base, engine
from app import models


# Create database tables
Base.metadata.create_all(bind=engine)


app = FastAPI(
    title="Hikmah Islamic Quizzes API",
    description="Backend API for the Hikmah Islamic Quizzes mobile application.",
    version="1.0.0"
)


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
