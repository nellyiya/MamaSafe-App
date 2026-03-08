import sys
import os
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from database import engine, SessionLocal, Base
from models import User, UserRole, UserStatus
from auth import get_password_hash

def init_db():
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("[OK] Tables created")
    
    db = SessionLocal()
    
    # Check if admin exists
    admin = db.query(User).filter(User.email == "admin@mamasafe.com").first()
    if not admin:
        print("Creating default admin user...")
        admin = User(
            name="Admin",
            email="admin@mamasafe.com",
            phone="+250788000000",
            password_hash=get_password_hash("admin123"),
            role=UserRole.ADMIN,
            is_approved=True,
            status=UserStatus.ACTIVE
        )
        db.add(admin)
        db.commit()
        print("[OK] Admin user created")
        print("   Email: admin@mamasafe.com")
        print("   Password: admin123")
    else:
        print("[INFO] Admin user already exists")
    
    db.close()
    print("\n[OK] Database initialization complete!")

if __name__ == "__main__":
    init_db()
