import sys
sys.path.append('c:\\Users\\Djafari\\Pictures\\done\\backend')

from database import SessionLocal
from models import User, UserRole

db = SessionLocal()

# Exact hospital names from Flutter app
hospitals = [
    "Kibagabaga Level Two Teaching Hospital",
    "Kacyiru District Hospital", 
    "King Faisal Hospital Rwanda",
    "University Teaching Hospital of Kigali (CHUK)",
    "Rwanda Military Hospital"
]

# Get all healthcare professionals
healthcare_pros = db.query(User).filter(User.role == UserRole.HEALTHCARE_PRO).all()

print("Assigning correct hospital names to healthcare professionals...")
for i, user in enumerate(healthcare_pros):
    hospital = hospitals[i % len(hospitals)]
    user.facility = hospital
    print(f"User {user.id} ({user.name}) -> {hospital}")

db.commit()
print("\nDone! Healthcare professionals assigned to hospitals.")
db.close()
