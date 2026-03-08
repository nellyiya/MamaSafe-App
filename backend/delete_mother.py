from database import SessionLocal
from models import Mother, HealthRecord, Visit, Referral

db = SessionLocal()

mother_id = 1
mother = db.query(Mother).filter(Mother.id == mother_id).first()

if mother:
    # Delete related records
    db.query(Referral).filter(Referral.mother_id == mother_id).delete()
    db.query(Visit).filter(Visit.mother_id == mother_id).delete()
    db.query(HealthRecord).filter(HealthRecord.mother_id == mother_id).delete()
    
    # Delete mother
    db.delete(mother)
    db.commit()
    print(f'Deleted mother: {mother.name}')
else:
    print('Mother not found')

db.close()
