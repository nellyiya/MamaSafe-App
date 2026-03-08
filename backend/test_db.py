from database import engine, SessionLocal
from models import User

print("Testing database connection...")

try:
    # Test connection
    with engine.connect() as conn:
        print("✅ Database connection successful")
    
    # Test session
    db = SessionLocal()
    user_count = db.query(User).count()
    print(f"✅ Query successful - Found {user_count} users")
    db.close()
    
    print("✅ All tests passed!")
except Exception as e:
    print(f"❌ Error: {e}")
