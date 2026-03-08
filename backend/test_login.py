import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
from models import User
from auth import verify_password

def test_login():
    db = SessionLocal()
    
    print("Checking database...")
    users = db.query(User).all()
    print(f"\nTotal users in database: {len(users)}")
    
    for user in users:
        print(f"\n  Email: {user.email}")
        print(f"  Name: {user.name}")
        print(f"  Role: {user.role}")
        print(f"  Approved: {user.is_approved}")
        print(f"  Password hash: {user.password_hash[:50]}...")
    
    print("\n" + "="*50)
    print("Testing login with: admin@mamasafe.com / admin123")
    print("="*50)
    
    admin = db.query(User).filter(User.email == "admin@mamasafe.com").first()
    
    if not admin:
        print("[ERROR] Admin user not found!")
        return
    
    print(f"\n[OK] Found user: {admin.name}")
    print(f"     Email: {admin.email}")
    print(f"     Approved: {admin.is_approved}")
    
    # Test password
    password = "admin123"
    if verify_password(password, admin.password_hash):
        print(f"\n[SUCCESS] Password '{password}' is CORRECT!")
    else:
        print(f"\n[FAILED] Password '{password}' is WRONG!")
        
        # Try other common passwords
        for test_pwd in ["Admin123", "ADMIN123", "admin", "password"]:
            if verify_password(test_pwd, admin.password_hash):
                print(f"[INFO] Correct password is: {test_pwd}")
                break
    
    db.close()

if __name__ == "__main__":
    test_login()
