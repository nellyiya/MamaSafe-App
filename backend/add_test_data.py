"""
Script to add test data to the database
"""
import sys
import os
from datetime import datetime, timedelta

# Add parent directory to path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import get_db
from models import User, Mother, Referral, UserRole, UserStatus, ReferralStatus, SeverityLevel
from auth import get_password_hash

def add_test_data():
    db = next(get_db())
    
    print("\n" + "="*50)
    print("ADDING TEST DATA")
    print("="*50 + "\n")
    
    try:
        # Check if CHW exists
        chw = db.query(User).filter(User.role == UserRole.CHW, User.is_approved == True).first()
        if not chw:
            print("Creating test CHW...")
            chw = User(
                name="Test CHW",
                email="chw@test.com",
                phone="0788888888",
                password_hash=get_password_hash("test123"),
                role=UserRole.CHW,
                district="Gasabo",
                sector="Kimironko",
                cell="Kibagabaga",
                village="Umudgudu",
                is_approved=True,
                status=UserStatus.ACTIVE
            )
            db.add(chw)
            db.commit()
            db.refresh(chw)
            print(f"✅ Created CHW: {chw.name} (ID: {chw.id})")
        else:
            print(f"✅ Using existing CHW: {chw.name} (ID: {chw.id})")
        
        # Check if Healthcare Pro exists
        healthcare_pro = db.query(User).filter(User.role == UserRole.HEALTHCARE_PRO, User.is_approved == True).first()
        if not healthcare_pro:
            print("Creating test Healthcare Professional...")
            healthcare_pro = User(
                name="Dr. Test",
                email="doctor@test.com",
                phone="0789999999",
                password_hash=get_password_hash("test123"),
                role=UserRole.HEALTHCARE_PRO,
                facility="King Faisal Hospital Rwanda",
                is_approved=True,
                status=UserStatus.ACTIVE
            )
            db.add(healthcare_pro)
            db.commit()
            db.refresh(healthcare_pro)
            print(f"✅ Created Healthcare Pro: {healthcare_pro.name} (ID: {healthcare_pro.id})")
        else:
            print(f"✅ Using existing Healthcare Pro: {healthcare_pro.name} (ID: {healthcare_pro.id})")
        
        # Add test mothers
        print("\nAdding test mothers...")
        
        mothers_data = [
            {"name": "Marie Uwase", "age": 28, "risk": "High", "cell": "Kibagabaga"},
            {"name": "Grace Mukamana", "age": 32, "risk": "High", "cell": "Kibagabaga"},
            {"name": "Jeanne Mukamazimpaka", "age": 25, "risk": "Medium", "cell": "Nyabisindu"},
            {"name": "Alice Uwamahoro", "age": 30, "risk": "Medium", "cell": "Nyabisindu"},
            {"name": "Sarah Ingabire", "age": 22, "risk": "Medium", "cell": "Kibagabaga"},
            {"name": "Rose Mukandori", "age": 27, "risk": "Low", "cell": "Nyabisindu"},
            {"name": "Claire Umutoni", "age": 24, "risk": "Low", "cell": "Kibagabaga"},
            {"name": "Diane Uwera", "age": 29, "risk": "Low", "cell": "Nyabisindu"},
        ]
        
        created_mothers = []
        for m_data in mothers_data:
            # Check if mother already exists
            existing = db.query(Mother).filter(Mother.name == m_data["name"]).first()
            if existing:
                print(f"   ⏭️  Mother already exists: {m_data['name']}")
                created_mothers.append(existing)
                continue
            
            mother = Mother(
                name=m_data["name"],
                age=m_data["age"],
                phone=f"078{7000000 + len(created_mothers)}",
                province="Kigali City",
                district="Gasabo",
                sector="Kimironko",
                cell=m_data["cell"],
                village="Umudgudu",
                pregnancy_start_date=datetime.now() - timedelta(days=120),
                due_date=datetime.now() + timedelta(days=150),
                created_by_chw_id=chw.id,
                current_risk_level=m_data["risk"]
            )
            db.add(mother)
            db.commit()
            db.refresh(mother)
            created_mothers.append(mother)
            print(f"   ✅ Created: {mother.name} ({mother.current_risk_level} risk)")
        
        # Add test referrals for high-risk mothers
        print("\nAdding test referrals...")
        high_risk_mothers = [m for m in created_mothers if m.current_risk_level == "High"]
        
        for i, mother in enumerate(high_risk_mothers):
            # Check if referral already exists
            existing_ref = db.query(Referral).filter(Referral.mother_id == mother.id).first()
            if existing_ref:
                print(f"   ⏭️  Referral already exists for: {mother.name}")
                continue
            
            status = ReferralStatus.PENDING if i == 0 else ReferralStatus.APPOINTMENT_SCHEDULED
            
            referral = Referral(
                mother_id=mother.id,
                chw_id=chw.id,
                healthcare_pro_id=healthcare_pro.id if status == ReferralStatus.APPOINTMENT_SCHEDULED else None,
                hospital="King Faisal Hospital Rwanda",
                severity=SeverityLevel.HIGH,
                notes="High blood pressure detected during routine checkup",
                status=status,
                risk_detected_time=datetime.now() - timedelta(hours=2),
                chw_confirmed_time=datetime.now() - timedelta(hours=1),
                hospital_received_time=datetime.now() if status == ReferralStatus.APPOINTMENT_SCHEDULED else None,
                appointment_date=datetime.now() + timedelta(days=2) if status == ReferralStatus.APPOINTMENT_SCHEDULED else None,
                appointment_time="10:00" if status == ReferralStatus.APPOINTMENT_SCHEDULED else None,
                department="Maternity" if status == ReferralStatus.APPOINTMENT_SCHEDULED else None
            )
            db.add(referral)
            db.commit()
            print(f"   ✅ Created referral for: {mother.name} ({status.value})")
        
        print("\n" + "="*50)
        print("✅ TEST DATA ADDED SUCCESSFULLY!")
        print("="*50 + "\n")
        print("You can now:")
        print("1. Login as admin (admin@mamasafe.rw / admin123)")
        print("2. View the dashboard with real data")
        print("3. Login as CHW (chw@test.com / test123)")
        print("4. Login as Healthcare Pro (doctor@test.com / test123)")
        print()
        
    except Exception as e:
        print(f"\n❌ Error: {e}")
        db.rollback()
    finally:
        db.close()

if __name__ == "__main__":
    add_test_data()
