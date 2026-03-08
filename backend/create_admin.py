from database import get_db
from models import User, UserRole, UserStatus
from auth import get_password_hash

def create_admin():
    db = next(get_db())
    
    # Check if admin exists
    admin = db.query(User).filter(User.email == 'admin@mamasafe.rw').first()
    
    if admin:
        print("Admin already exists!")
        print(f"Email: {admin.email}")
        print(f"Role: {admin.role}")
        return
    
    # Create admin user
    admin = User(
        name="Admin",
        email="admin@mamasafe.rw",
        phone="0788000000",
        password_hash=get_password_hash("admin123"),
        role=UserRole.ADMIN,
        is_approved=True,
        status=UserStatus.ACTIVE
    )
    
    db.add(admin)
    db.commit()
    db.refresh(admin)
    
    print("Admin account created successfully!")
    print(f"Email: admin@mamasafe.rw")
    print(f"Password: admin123")
    print(f"Role: {admin.role}")

if __name__ == "__main__":
    create_admin()
