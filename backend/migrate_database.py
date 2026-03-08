"""
Database migration script to update schema for new MamaSafe features
"""
import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(__file__), "mamasafe.db")

def migrate():
    conn = sqlite3.connect(DB_PATH)
    cursor = conn.cursor()
    
    print("Starting database migration...")
    
    # Add new columns to mothers table
    try:
        cursor.execute("ALTER TABLE mothers ADD COLUMN province TEXT")
        print("+ Added province to mothers")
    except sqlite3.OperationalError:
        print("- province already exists in mothers")
    
    try:
        cursor.execute("ALTER TABLE mothers ADD COLUMN cell TEXT")
        print("+ Added cell to mothers")
    except sqlite3.OperationalError:
        print("- cell already exists in mothers")
    
    # Add new columns to referrals table
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN severity TEXT")
        print("+ Added severity to referrals")
    except sqlite3.OperationalError:
        print("- severity already exists in referrals")
    
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN risk_detected_time TIMESTAMP")
        print("+ Added risk_detected_time to referrals")
    except sqlite3.OperationalError:
        print("- risk_detected_time already exists in referrals")
    
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN chw_confirmed_time TIMESTAMP")
        print("+ Added chw_confirmed_time to referrals")
    except sqlite3.OperationalError:
        print("- chw_confirmed_time already exists in referrals")
    
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN hospital_received_time TIMESTAMP")
        print("+ Added hospital_received_time to referrals")
    except sqlite3.OperationalError:
        print("- hospital_received_time already exists in referrals")
    
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN appointment_date TIMESTAMP")
        print("+ Added appointment_date to referrals")
    except sqlite3.OperationalError:
        print("- appointment_date already exists in referrals")
    
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN appointment_time TEXT")
        print("+ Added appointment_time to referrals")
    except sqlite3.OperationalError:
        print("- appointment_time already exists in referrals")
    
    try:
        cursor.execute("ALTER TABLE referrals ADD COLUMN department TEXT")
        print("+ Added department to referrals")
    except sqlite3.OperationalError:
        print("- department already exists in referrals")
    
    # Update existing mothers with default values
    cursor.execute("UPDATE mothers SET province = 'Kigali City' WHERE province IS NULL")
    cursor.execute("UPDATE mothers SET cell = '' WHERE cell IS NULL")
    print("+ Updated existing mothers with default values")
    
    conn.commit()
    conn.close()
    
    print("\n=== Migration completed successfully!")

if __name__ == "__main__":
    migrate()
