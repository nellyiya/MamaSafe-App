from sqlalchemy import create_engine, text

engine = create_engine('sqlite:///mamasafe.db')

with engine.connect() as conn:
    # Check distinct statuses
    result = conn.execute(text('SELECT DISTINCT status FROM referrals'))
    print("Distinct statuses in database:")
    for row in result:
        print(f"  - '{row[0]}'")
    
    # Check mothers with scheduled appointments
    result = conn.execute(text("""
        SELECT m.id, m.name, r.status 
        FROM mothers m 
        JOIN referrals r ON m.id = r.mother_id 
        WHERE r.status LIKE '%Appointment%'
    """))
    print("\nMothers with appointment-related statuses:")
    for row in result:
        print(f"  Mother ID {row[0]}: {row[1]} - Status: '{row[2]}'")
