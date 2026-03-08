from database import get_db
from models import User, Mother, UserRole

db = next(get_db())

chws = db.query(User).filter(User.role == UserRole.CHW).all()
print(f'Total CHWs: {len(chws)}')

for chw in chws:
    mothers = db.query(Mother).filter(Mother.created_by_chw_id == chw.id).count()
    print(f'  - {chw.name}: {mothers} mothers')

total = db.query(Mother).count()
print(f'\nTotal mothers in system: {total}')
