import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
from models import User

def check_users():
    db = SessionLocal()
    
    print("\n" + "="*60)
    print("ALL USERS IN DATABASE")
    print("="*60)
    
    users = db.query(User).all()
    
    for user in users:
        print(f"\nID: {user.id}")
        print(f"Name: {user.name}")
        print(f"Email: {user.email}")
        print(f"Role: {user.role}")
        print(f"Approved: {user.is_approved}")
        print(f"Status: {user.status}")
        print(f"Village: {user.village}")
        print("-" * 60)
    
    db.close()

if __name__ == "__main__":
    check_users()
