"""
Migration script: SQLite to Supabase PostgreSQL
Exports all data from SQLite and imports to PostgreSQL
"""
import sqlite3
import psycopg2
from psycopg2.extras import execute_values
import os
from dotenv import load_dotenv

load_dotenv()

# Paths
SQLITE_DB = "mamasafe.db"
POSTGRES_URL = os.getenv("DATABASE_URL")

if not POSTGRES_URL:
    print("ERROR: DATABASE_URL not found in .env file")
    exit(1)

# Parse PostgreSQL URL
# Format: postgresql://user:password@host:port/database
url_parts = POSTGRES_URL.replace("postgresql://", "").split("@")
user_pass = url_parts[0].split(":")
host_db = url_parts[1].split("/")
host_port = host_db[0].split(":")

PG_CONFIG = {
    "user": user_pass[0],
    "password": user_pass[1],
    "host": host_port[0],
    "port": host_port[1],
    "database": host_db[1]
}

def migrate_data():
    print("Starting migration from SQLite to PostgreSQL...")
    
    # Connect to SQLite
    sqlite_conn = sqlite3.connect(SQLITE_DB)
    sqlite_conn.row_factory = sqlite3.Row
    sqlite_cur = sqlite_conn.cursor()
    
    # Connect to PostgreSQL
    pg_conn = psycopg2.connect(**PG_CONFIG)
    pg_cur = pg_conn.cursor()
    
    # Tables to migrate in order (respecting foreign keys)
    tables = ["users", "mothers", "health_records", "visits", "referrals"]
    
    for table in tables:
        print(f"\nMigrating {table}...")
        
        # Get data from SQLite
        sqlite_cur.execute(f"SELECT * FROM {table}")
        rows = sqlite_cur.fetchall()
        
        if not rows:
            print(f"  No data in {table}")
            continue
        
        # Get column names
        columns = [description[0] for description in sqlite_cur.description]
        
        # Prepare INSERT statement
        cols_str = ", ".join(columns)
        placeholders = ", ".join(["%s"] * len(columns))
        insert_sql = f"INSERT INTO {table} ({cols_str}) VALUES ({placeholders}) ON CONFLICT DO NOTHING"
        
        # Convert rows to tuples
        data = [tuple(row) for row in rows]
        
        # Insert into PostgreSQL
        execute_values(pg_cur, insert_sql, data, template=None, page_size=100)
        pg_conn.commit()
        
        print(f"  Migrated {len(data)} rows")
    
    # Update sequences for auto-increment columns
    print("\nUpdating sequences...")
    for table in tables:
        pg_cur.execute(f"SELECT setval(pg_get_serial_sequence('{table}', 'id'), COALESCE(MAX(id), 1)) FROM {table}")
    pg_conn.commit()
    
    # Close connections
    sqlite_conn.close()
    pg_conn.close()
    
    print("\n✅ Migration completed successfully!")
    print("Your data is now in Supabase PostgreSQL")

if __name__ == "__main__":
    try:
        migrate_data()
    except Exception as e:
        print(f"\n❌ Migration failed: {e}")
        import traceback
        traceback.print_exc()
