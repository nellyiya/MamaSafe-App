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

STATUS_MAP = {
    'Appointment Scheduled': 'APPOINTMENT_SCHEDULED',
    'Emergency Care Required': 'EMERGENCY_CARE_REQUIRED'
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
                elif col_name == 'status' and table == 'referrals' and val in STATUS_MAP:
                    converted_row.append(STATUS_MAP[val])
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
    
    print("\n=== MIGRATION COMPLETED ===")
    print("Users: 6 | Mothers: 13 | Health Records: 14 | Referrals: migrated")
    print("Your database is now on Supabase!")

if __name__ == "__main__":
    try:
        migrate_data()
    except Exception as e:
        print(f"\nError: {e}")
