from database import get_db
from models import User
from auth import get_password_hash

def reset_admin_password():
    db = next(get_db())
    
    # Get admin user
    admin = db.query(User).filter(User.email == 'admin@mamasafe.rw').first()
    
    if not admin:
        print("Admin account not found!")
        return
    
    # Reset password to admin123
    admin.password_hash = get_password_hash("admin123")
    db.commit()
    
    print("Admin password reset successfully!")
    print(f"Email: admin@mamasafe.rw")
    print(f"Password: admin123")

if __name__ == "__main__":
    reset_admin_password()
