import sys
sys.path.append('c:\\Users\\Djafari\\Pictures\\done\\backend')

from database import SessionLocal
from models import Referral

db = SessionLocal()

# Mapping old names to correct names
hospital_mapping = {
    "Kibagabaga Hospital": "Kibagabaga Level Two Teaching Hospital",
    "King Faisal Hospital": "King Faisal Hospital Rwanda",
    "Kacyiru District Hospital": "Kacyiru District Hospital",  # Already correct
    "Muhima Hospital": "Kacyiru District Hospital",  # Map to closest
    "Rwanda Military Hospital": "Rwanda Military Hospital"  # Already correct
}

referrals = db.query(Referral).all()

print("Updating referral hospital names...")
for ref in referrals:
    old_name = ref.hospital
    new_name = hospital_mapping.get(old_name, old_name)
    if old_name != new_name:
        ref.hospital = new_name
        print(f"Referral {ref.id}: '{old_name}' -> '{new_name}'")
    else:
        print(f"Referral {ref.id}: '{old_name}' (no change)")

db.commit()
print("\nDone! All referrals updated.")
db.close()
