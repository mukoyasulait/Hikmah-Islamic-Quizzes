
from getpass import getpass

from sqlalchemy import select

from app.database import SessionLocal
from app.models.user import User
from app.services.security import hash_password


db = SessionLocal()

try:
    email = "admin@gmail.com"
    username = "admin"

    existing_user = db.scalar(
        select(User).where(User.email == email)
    )

    if existing_user:
        print("An account with this email already exists.")
    else:
        password = getpass("Enter the administrator password: ")
        confirm_password = getpass("Confirm the password: ")

        if password != confirm_password:
            print("Passwords do not match.")
        elif len(password) < 8:
            print("Password must contain at least 8 characters.")
        else:
            admin = User(
                username=username,
                email=email,
                password_hash=hash_password(password),
                role="admin"
            )

            db.add(admin)
            db.commit()

            print("Administrator account created successfully!")

except Exception as error:
    db.rollback()
    print("Error:", error)

finally:
    db.close()
