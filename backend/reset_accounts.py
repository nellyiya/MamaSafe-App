from database import SessionLocal
from models import User, Mother, HealthRecord, Visit, Referral, UserRole

db = SessionLocal()

print("Deleting all accounts except Admin...")
print("=" * 50)

# Delete all referrals
referral_count = db.query(Referral).delete()
print(f"Deleted {referral_count} referrals")

# Delete all visits
visit_count = db.query(Visit).delete()
print(f"Deleted {visit_count} visits")

# Delete all health records
health_count = db.query(HealthRecord).delete()
print(f"Deleted {health_count} health records")

# Delete all mothers
mother_count = db.query(Mother).delete()
print(f"Deleted {mother_count} mothers")

# Delete all non-admin users
non_admin_users = db.query(User).filter(User.role != UserRole.ADMIN).all()
user_count = len(non_admin_users)
for user in non_admin_users:
    db.delete(user)

db.commit()
print(f"Deleted {user_count} non-admin users")

print("=" * 50)
print("Database cleaned! Only Admin account remains.")
print("=" * 50)
print("Admin Login:")
print("Email: admin@mamasafe.rw")
print("Password: Admin@2024")
print("=" * 50)

db.close()
