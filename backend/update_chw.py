import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

from database import SessionLocal
from models import User

def update_chw_village():
    db = SessionLocal()
    
    # Update Nelly's village
    chw = db.query(User).filter(User.email == "iyabikoze@gmail.com").first()
    
    if chw:
        chw.village = "Kigali"
        chw.cell = "Kigali"
        chw.sector = "Kigali"
        chw.district = "Kigali"
        
        db.commit()
        print(f"[OK] Updated {chw.name}'s location:")
        print(f"   District: {chw.district}")
        print(f"   Sector: {chw.sector}")
        print(f"   Cell: {chw.cell}")
        print(f"   Village: {chw.village}")
    else:
        print("[ERROR] CHW not found")
    
    db.close()

if __name__ == "__main__":
    update_chw_village()
