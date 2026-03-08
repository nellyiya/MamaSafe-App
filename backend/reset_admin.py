import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
from models import User, UserRole, UserStatus
from auth import get_password_hash, verify_password

def reset_admin():
    db = SessionLocal()
    
    # Delete existing admin
    db.query(User).filter(User.email == "admin@mamasafe.com").delete()
    db.commit()
    
    print("Creating new admin user...")
    
    # Create new admin with correct password
    password = "admin123"
    hashed = get_password_hash(password)
    
    admin = User(
        name="Admin",
        email="admin@mamasafe.com",
        phone="+250788000000",
        password_hash=hashed,
        role=UserRole.ADMIN,
        is_approved=True,
        status=UserStatus.ACTIVE
    )
    
    db.add(admin)
    db.commit()
    db.refresh(admin)
    
    # Verify the password works
    print("\nVerifying password...")
    if verify_password(password, admin.password_hash):
        print("[OK] Password verification successful!")
    else:
        print("[ERROR] Password verification failed!")
    
    print("\nAdmin user created:")
    print(f"  Email: {admin.email}")
    print(f"  Password: {password}")
    print(f"  Role: {admin.role}")
    print(f"  Approved: {admin.is_approved}")
    
    db.close()

if __name__ == "__main__":
    reset_admin()
