import sqlite3
import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

SQLITE_DB = "mamasafe.db"
POSTGRES_URL = os.getenv("DATABASE_URL")

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
        
        for row in rows:
            placeholders = ", ".join(["%s"] * len(columns))
            cols = ", ".join(columns)
            sql = f"INSERT INTO {table} ({cols}) VALUES ({placeholders}) ON CONFLICT DO NOTHING"
            pg_cur.execute(sql, tuple(row))
        
        pg_conn.commit()
        print(f"  Migrated {len(rows)} rows")
    
    print("\nUpdating sequences...")
    for table in tables:
        pg_cur.execute(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), COALESCE(MAX(id), 1)) FROM {table}")
    pg_conn.commit()
    
    sqlite_conn.close()
    pg_conn.close()
    
    print("\nMigration completed!")

if __name__ == "__main__":
    try:
        migrate_data()
    except Exception as e:
        print(f"\nFailed: {e}")
