import psycopg2
import os
from dotenv import load_dotenv

load_dotenv()

# Try different connection methods
connections = [
    # Direct connection
    "postgresql://postgres:MamaSafe#2026Secure!@db.tenjkukjxfkbrdsfigyq.supabase.co:5432/postgres",
    # Pooler connection (Transaction mode)
    "postgresql://postgres.tenjkukjxfkbrdsfigyq:MamaSafe#2026Secure!@aws-0-us-east-1.pooler.supabase.com:6543/postgres",
    # Pooler connection (Session mode) 
    "postgresql://postgres.tenjkukjxfkbrdsfigyq:MamaSafe#2026Secure!@aws-0-us-east-1.pooler.supabase.com:5432/postgres",
]

for i, conn_str in enumerate(connections, 1):
    print(f"\nTrying connection method {i}...")
    try:
        conn = psycopg2.connect(conn_str)
        print(f"✅ SUCCESS with method {i}!")
        print(f"Connection string: {conn_str.split('@')[1]}")
        conn.close()
        
        # Update .env with working connection
        with open('.env', 'w') as f:
            f.write(f"DATABASE_URL={conn_str}\n")
            f.write("SECRET_KEY=mamasafe-secret-key-2026-production-secure\n")
            f.write("ALGORITHM=HS256\n")
            f.write("ACCESS_TOKEN_EXPIRE_MINUTES=10080\n")
        print("✅ Updated .env file")
        break
    except Exception as e:
        print(f"❌ Failed: {str(e)[:100]}")
else:
    print("\n❌ All connection methods failed. Check your internet/firewall.")
