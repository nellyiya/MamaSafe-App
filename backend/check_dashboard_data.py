import sqlite3
from datetime import datetime

# Connect to database
conn = sqlite3.connect('mamasafe.db')
cursor = conn.cursor()

print("=" * 60)
print("CHECKING DASHBOARD DATA")
print("=" * 60)

# Get CHW ID (assuming first CHW)
cursor.execute("SELECT id, name FROM users WHERE role = 'CHW' LIMIT 1")
chw = cursor.fetchone()
if not chw:
    print("No CHW found in database")
    exit()

chw_id, chw_name = chw
print(f"\nCHW: {chw_name} (ID: {chw_id})")

# Total mothers
cursor.execute("SELECT COUNT(*) FROM mothers WHERE created_by_chw_id = ?", (chw_id,))
total_mothers = cursor.fetchone()[0]
print(f"\nTotal Mothers: {total_mothers}")

# Risk levels
cursor.execute("""
    SELECT current_risk_level, COUNT(*) 
    FROM mothers 
    WHERE created_by_chw_id = ? 
    GROUP BY current_risk_level
""", (chw_id,))
risk_data = cursor.fetchall()
print("\nRisk Levels:")
for risk, count in risk_data:
    print(f"   - {risk}: {count}")

# Count by specific risk levels
cursor.execute("SELECT COUNT(*) FROM mothers WHERE created_by_chw_id = ? AND current_risk_level = 'High'", (chw_id,))
high_risk = cursor.fetchone()[0]

cursor.execute("SELECT COUNT(*) FROM mothers WHERE created_by_chw_id = ? AND current_risk_level IN ('Medium', 'Mid')", (chw_id,))
mid_risk = cursor.fetchone()[0]

cursor.execute("SELECT COUNT(*) FROM mothers WHERE created_by_chw_id = ? AND current_risk_level = 'Low'", (chw_id,))
low_risk = cursor.fetchone()[0]

print(f"\nDashboard Counts:")
print(f"   - High Risk: {high_risk}")
print(f"   - Mid Risk: {mid_risk}")
print(f"   - Low Risk: {low_risk}")

# Active referrals
cursor.execute("""
    SELECT COUNT(*) 
    FROM referrals 
    WHERE chw_id = ? AND status != 'Completed'
""", (chw_id,))
active_referrals = cursor.fetchone()[0]
print(f"   - Active Referrals: {active_referrals}")

# Scheduled appointments
cursor.execute("""
    SELECT COUNT(*) 
    FROM referrals 
    WHERE chw_id = ? AND status = 'Appointment Scheduled'
""", (chw_id,))
scheduled_appointments = cursor.fetchone()[0]
print(f"   - Scheduled Appointments: {scheduled_appointments}")

# Show all referrals with status
cursor.execute("""
    SELECT r.id, m.name, r.status, r.appointment_date, r.appointment_time
    FROM referrals r
    JOIN mothers m ON r.mother_id = m.id
    WHERE r.chw_id = ?
""", (chw_id,))
referrals = cursor.fetchall()

print(f"\nAll Referrals ({len(referrals)}):")
for ref_id, mother_name, status, appt_date, appt_time in referrals:
    print(f"   - {mother_name}: {status}")
    if appt_date:
        print(f"     Appointment: {appt_date} at {appt_time}")

conn.close()
print("\n" + "=" * 60)
