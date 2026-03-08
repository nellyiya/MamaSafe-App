import sqlite3

# Connect to database
conn = sqlite3.connect('mamasafe.db')
cursor = conn.cursor()

print("Fixing referral status values...")

# Update APPOINTMENT_SCHEDULED to Appointment Scheduled
cursor.execute("""
    UPDATE referrals 
    SET status = 'Appointment Scheduled' 
    WHERE status = 'APPOINTMENT_SCHEDULED'
""")
affected = cursor.rowcount
print(f"Updated {affected} referrals with APPOINTMENT_SCHEDULED -> Appointment Scheduled")

# Update EMERGENCY_CARE_REQUIRED to Emergency Care Required  
cursor.execute("""
    UPDATE referrals 
    SET status = 'Emergency Care Required' 
    WHERE status = 'EMERGENCY_CARE_REQUIRED'
""")
affected = cursor.rowcount
print(f"Updated {affected} referrals with EMERGENCY_CARE_REQUIRED -> Emergency Care Required")

# Update PENDING to Pending (if needed)
cursor.execute("""
    UPDATE referrals 
    SET status = 'Pending' 
    WHERE status = 'PENDING'
""")
affected = cursor.rowcount
print(f"Updated {affected} referrals with PENDING -> Pending")

# Update RECEIVED to Received (if needed)
cursor.execute("""
    UPDATE referrals 
    SET status = 'Received' 
    WHERE status = 'RECEIVED'
""")
affected = cursor.rowcount
print(f"Updated {affected} referrals with RECEIVED -> Received")

# Update COMPLETED to Completed (if needed)
cursor.execute("""
    UPDATE referrals 
    SET status = 'Completed' 
    WHERE status = 'COMPLETED'
""")
affected = cursor.rowcount
print(f"Updated {affected} referrals with COMPLETED -> Completed")

conn.commit()

# Verify the fix
cursor.execute("SELECT status, COUNT(*) FROM referrals GROUP BY status")
print("\nCurrent status distribution:")
for status, count in cursor.fetchall():
    print(f"  - {status}: {count}")

conn.close()
print("\nDone!")
