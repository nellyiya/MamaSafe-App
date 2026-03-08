"""
Recreate database with new schema including medical history fields
"""
import os
import sys

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import engine, Base
from models import User, Mother, HealthRecord, Visit, Referral, UserRole, UserStatus
from auth import get_password_hash

# Delete old database
db_path = "mamasafe.db"
if os.path.exists(db_path):
    os.remove(db_path)
    print(f"Deleted old database: {db_path}")

# Create all tables with new schema
Base.metadata.create_all(bind=engine)
print("Created new database with updated schema")

# Create admin account
from sqlalchemy.orm import Session
db = Session(engine)

admin = User(
    name="Admin",
    email="admin@mamasafe.rw",
    phone="0788000000",
    password_hash=get_password_hash("Admin@2024"),
    role=UserRole.ADMIN,
    is_approved=True,
    status=UserStatus.ACTIVE
)
db.add(admin)
db.commit()
print("Created admin account")
print("Email: admin@mamasafe.rw")
print("Password: Admin@2024")

db.close()
print("\nDatabase recreated successfully!")
