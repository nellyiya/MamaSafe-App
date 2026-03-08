"""
Script to check database contents and add test data if needed
"""
import sys
import os
from datetime import datetime, timedelta

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import get_db
from models import User, Mother, Referral, UserRole, UserStatus, ReferralStatus

def check_database():
    db = next(get_db())
    
    print("\n" + "="*50)
    print("DATABASE CONTENTS CHECK")
    print("="*50 + "\n")
    
    # Check users
    total_users = db.query(User).count()
    chws = db.query(User).filter(User.role == UserRole.CHW, User.is_approved == True).count()
    healthcare_pros = db.query(User).filter(User.role == UserRole.HEALTHCARE_PRO, User.is_approved == True).count()
    admins = db.query(User).filter(User.role == UserRole.ADMIN).count()
    
    print(f"👥 USERS:")
    print(f"   Total: {total_users}")
    print(f"   CHWs (approved): {chws}")
    print(f"   Healthcare Pros (approved): {healthcare_pros}")
    print(f"   Admins: {admins}")
    
    # Check mothers
    total_mothers = db.query(Mother).count()
    high_risk = db.query(Mother).filter(Mother.current_risk_level == "High").count()
    medium_risk = db.query(Mother).filter(Mother.current_risk_level.in_(["Medium", "Mid"])).count()
    low_risk = db.query(Mother).filter(Mother.current_risk_level == "Low").count()
    
    print(f"\n👩 MOTHERS:")
    print(f"   Total: {total_mothers}")
    print(f"   High Risk: {high_risk}")
    print(f"   Medium Risk: {medium_risk}")
    print(f"   Low Risk: {low_risk}")
    
    # Check referrals
    total_referrals = db.query(Referral).count()
    pending = db.query(Referral).filter(Referral.status == ReferralStatus.PENDING).count()
    scheduled = db.query(Referral).filter(Referral.status == ReferralStatus.APPOINTMENT_SCHEDULED).count()
    completed = db.query(Referral).filter(Referral.status == ReferralStatus.COMPLETED).count()
    
    print(f"\n🏥 REFERRALS:")
    print(f"   Total: {total_referrals}")
    print(f"   Pending: {pending}")
    print(f"   Scheduled: {scheduled}")
    print(f"   Completed: {completed}")
    
    print("\n" + "="*50 + "\n")
    
    # If no data, offer to add test data
    if total_mothers == 0:
        print("⚠️  No mothers found in database!")
        print("This is why your admin dashboard shows zeros.")
        print("\nTo add test data:")
        print("1. Register as a CHW through the app")
        print("2. Admin approves the CHW")
        print("3. CHW adds mothers and runs predictions")
        print("\nOr run: python add_test_data.py")
    
    db.close()

if __name__ == "__main__":
    check_database()
