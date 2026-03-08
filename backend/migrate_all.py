import sqlite3
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

SQLITE_DB = "mamasafe.db"
POSTGRES_URL = os.getenv("DATABASE_URL")

BOOLEAN_COLUMNS = {
    'users': ['is_approved'],
    'mothers': ['has_allergies', 'has_chronic_condition', 'on_medication'],
    'visits': ['completed']
}

REFERRAL_STATUS_MAP = {
    'Pending': 'PENDING',
    'Received': 'RECEIVED',
    'Appointment Scheduled': 'APPOINTMENT_SCHEDULED',
    'Emergency Care Required': 'EMERGENCY_CARE_REQUIRED',
    'Completed': 'COMPLETED'
}

SEVERITY_MAP = {
    'Critical': 'CRITICAL',
    'Moderate': 'MODERATE',
    'Lower': 'LOWER'
}

USER_STATUS_MAP = {
    'Pending': 'PENDING',
    'Active': 'ACTIVE',
    'Suspended': 'SUSPENDED'
}

USER_ROLE_MAP = {
    'Admin': 'ADMIN',
    'CHW': 'CHW',
    'HealthcarePro': 'HEALTHCARE_PRO'
}

def migrate_data():
    print("Starting migration...")
    
    sqlite_conn = sqlite3.connect(SQLITE_DB)
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cur = sqlite_conn.cursor()
    
    pg_conn = psycopg2.connect(POSTGRES_URL)
    pg_cur = pg_conn.cursor()
    
    tables = ["users", "mothers", "health_records", "visits", "referrals"]
    
    for table in tables:
        print(f"\nMigrating {table}...")
        
        sqlite_cur.execute(f"SELECT * FROM {table}")
        rows = sqlite_cur.fetchall()
        
        if not rows:
            print(f"  No data")
            continue
        
        columns = [d[0] for d in sqlite_cur.description]
        bool_cols = BOOLEAN_COLUMNS.get(table, [])
        
        for row in rows:
            converted_row = []
            for i, val in enumerate(row):
                col_name = columns[i]
                
                if col_name in bool_cols and isinstance(val, int):
                    converted_row.append(bool(val))
                elif table == 'referrals' and col_name == 'status' and val in REFERRAL_STATUS_MAP:
                    converted_row.append(REFERRAL_STATUS_MAP[val])
                elif table == 'referrals' and col_name == 'severity' and val in SEVERITY_MAP:
                    converted_row.append(SEVERITY_MAP[val])
                elif table == 'users' and col_name == 'status' and val in USER_STATUS_MAP:
                    converted_row.append(USER_STATUS_MAP[val])
                elif table == 'users' and col_name == 'role' and val in USER_ROLE_MAP:
                    converted_row.append(USER_ROLE_MAP[val])
                else:
                    converted_row.append(val)
            
            placeholders = ", ".join(["%s"] * len(columns))
            cols = ", ".join(columns)
            sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders}) ON CONFLICT DO NOTHING"
            pg_cur.execute(sql, tuple(converted_row))
        
        pg_conn.commit()
        print(f"  Migrated {len(rows)} rows")
    
    print("\nUpdating sequences...")
    for table in tables:
        pg_cur.execute(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), COALESCE(MAX(id), 1)) FROM {table}")
    pg_conn.commit()
    
    sqlite_conn.close()
    pg_conn.close()
    
    print("\n" + "="*50)
    print("MIGRATION COMPLETED SUCCESSFULLY!")
    print("="*50)
    print("All your data is now in Supabase PostgreSQL")
    print("You can access it at: https://supabase.com/dashboard")

if __name__ == "__main__":
    try:
        migrate_data()
    except Exception as e:
        print(f"\nError: {e}")
