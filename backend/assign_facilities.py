import sys
sys.path.append('c:\\Users\\Djafari\\Pictures\\done\\backend')

from database import SessionLocal
from models import User, UserRole

db = SessionLocal()

# Get all healthcare professionals
healthcare_pros = db.query(User).filter(User.role == UserRole.HEALTHCARE_PRO).all()

hospitals = [
    "Kibagabaga Hospital",
    "Kacyiru District Hospital", 
    "King Faisal Hospital",
    "CHUK (Centre Hospitalier Universitaire de Kigali)",
    "Rwanda Military Hospital"
]

print("Assigning facilities to healthcare professionals...")
for i, user in enumerate(healthcare_pros):
    hospital = hospitals[i % len(hospitals)]
    user.facility = hospital
    print(f"[OK] User {user.id} ({user.name}) -> {hospital}")

db.commit()
print("\n[OK] All healthcare professionals assigned to facilities!")
db.close()
