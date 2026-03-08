import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
from models import User, Referral, Mother

db = SessionLocal()

print("\n" + "="*60)
print("DATABASE DEBUG - REFERRAL FILTERING")
print("="*60)

# Check all users
print("\nALL USERS:")
users = db.query(User).all()
for user in users:
    print(f"  ID: {user.id}, Name: {user.name}, Role: {user.role}, Facility: {user.facility}")

# Check all referrals
print("\nALL REFERRALS:")
referrals = db.query(Referral).all()
for ref in referrals:
    mother = db.query(Mother).filter(Mother.id == ref.mother_id).first()
    print(f"  ID: {ref.id}, Mother: {mother.name if mother else 'Unknown'}, Hospital: '{ref.hospital}', Status: {ref.status}")

# Check healthcare professionals
print("\nHEALTHCARE PROFESSIONALS:")
healthcare_pros = db.query(User).filter(User.role == "HealthcarePro").all()
for hp in healthcare_pros:
    print(f"  ID: {hp.id}, Name: {hp.name}, Facility: '{hp.facility}'")
    
    # Check matching referrals
    matching_refs = db.query(Referral).filter(
        Referral.hospital == hp.facility,
        Referral.status == "Pending"
    ).all()
    print(f"    -> Matching referrals: {len(matching_refs)}")
    for ref in matching_refs:
        mother = db.query(Mother).filter(Mother.id == ref.mother_id).first()
        print(f"      - Referral #{ref.id}: {mother.name if mother else 'Unknown'} (Hospital: '{ref.hospital}')")

print("\n" + "="*60)
print("DIAGNOSIS:")
print("="*60)

if not healthcare_pros:
    print("ERROR: No healthcare professionals found in database")
elif not referrals:
    print("ERROR: No referrals found in database")
else:
    for hp in healthcare_pros:
        matching = [r for r in referrals if r.hospital == hp.facility and r.status == "Pending"]
        if not matching:
            print(f"WARNING: Healthcare Pro '{hp.name}' at '{hp.facility}' has NO matching referrals")
            print(f"   Available hospitals in referrals: {set(r.hospital for r in referrals)}")
            print(f"   Tip: Check if hospital names match exactly (case-sensitive)")
        else:
            print(f"SUCCESS: Healthcare Pro '{hp.name}' at '{hp.facility}' has {len(matching)} matching referral(s)")

db.close()
