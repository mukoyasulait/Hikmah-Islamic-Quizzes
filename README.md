# Hikmah Islamic Quizzes Mobile Application

### An Interactive Islamic Studies Quiz and Assessment Application

## 1. About the Project

Hikmah Islamic Quizzes is a mobile application developed to help university students and general Islamic learners test, improve and evaluate their understanding of Islamic knowledge through interactive quizzes.

The application provides questions covering different areas of Islamic Studies, allowing users to participate in assessments, receive instant results, view correct answers and explanations, track their performance and compare their rankings through leaderboards.

The application uses English as its primary language, with Arabic text and transliteration included where relevant.

## 2. Project Objectives

- To provide a mobile platform for Islamic Studies assessments.
- To organise Islamic knowledge into different quiz categories.
- To allow users to participate in interactive quizzes.
- To provide automatic scoring and answer explanations.
- To track users' quiz performance and assessment history.
- To encourage participation through competitive leaderboards.
- To provide administrators with tools to manage quiz questions and categories.

## 3. Target Users

The application is designed for:

- University students.
- General Islamic learners.
- Muslims interested in testing their Islamic knowledge.
- Administrators responsible for managing quiz content.

## 4. Main Features

### User Authentication
- User registration.
- Secure login and logout.
- User profile management.
- Role-based access control.

### Islamic Studies Categories
The application will initially cover:

1. Ulum al-Quran (Quranic Studies).
2. Hadith Studies.
3. Fiqh (Islamic Jurisprudence).
4. Aqeedah (Islamic Creed).
5. Islamic History.
6. Akhlaq (Islamic Ethics and Morality).

### Quiz System
- Multiple-choice questions.
- Beginner, Intermediate and Advanced difficulty levels.
- Category-based quizzes.
- Automatic answer evaluation.
- Automatic score calculation.
- Quiz results and explanations.

### Performance Tracking
- Personal quiz history.
- Previous assessment results.
- Individual performance statistics.
- Percentage scores.

### Leaderboard
- Weekly leaderboard.
- Overall leaderboard.
- Performance-based rankings.

### Administration
- Create and manage quiz categories.
- Add and manage questions.
- Manage answer options.
- Set correct answers.
- Add explanations and source references.
- Manage registered users.

## 5. Technologies Used

| Technology | Purpose |
|---|---|
| Flutter | Mobile application development |
| Dart | Application programming language |
| Python | Backend programming |
| FastAPI | REST API development |
| SQLite | Relational database |
| Visual Studio Code | Development environment |
| Git | Version control |
| GitHub | Source code hosting |

## 6. Application Design

The application will use a modern Islamic-inspired interface.

**Colour Scheme:**
- Deep Green: #064E3B
- Emerald Green: #059669
- Ivory: #F8F7F0
- Gold: #D4AF37

The interface will prioritise simplicity, readability and ease of navigation.

## 7. Database Design

The proposed database will contain the following tables:

1. Users
2. Categories
3. Questions
4. QuestionOptions
5. QuizAttempts
6. UserAnswers
7. Badges

## 8. System Architecture

Hikmah Islamic Quizzes will use a client-server architecture.

The Flutter mobile application will communicate with a Python FastAPI backend through REST API endpoints. The backend will process requests and interact with the SQLite database.

## 9. Project Structure

Hikmah-Islamic-Quizzes/
│
├── app/
│   └── Flutter mobile application
│
├── backend/
│   └── Python FastAPI backend
│
├── docs/
│   ├── project-proposal.pdf
│   ├── system-design.pdf
│   ├── ERD.png
│   └── API-documentation.md
│
├── README.md
└── .gitignore
```

## 10. Security

The application will implement:

- Password hashing.
- JWT-based authentication.
- Protected API endpoints.
- Role-based access control.
- Input validation.
- User-specific access to personal quiz records.

## 11. Development Approach

The project will be developed incrementally through the following stages:

1. System analysis and design.
2. Database design and implementation.
3. Backend API development.
4. Flutter mobile application development.
5. Backend and mobile application integration.
6. System testing and debugging.
7. Documentation and final demonstration.

## 12. Expected Outcome

The expected outcome is a functional Android mobile application that enables users to participate in Islamic Studies quizzes, evaluate their knowledge, view explanations, monitor their performance and compare their rankings with other learners.

**Hikmah Islamic Quizzes**

*Test Your Knowledge. Strengthen Your Understanding.*
