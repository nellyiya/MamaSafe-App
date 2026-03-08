# 🚀 SQLite to Supabase Migration Guide

## Step 1: Create Supabase Project (5 minutes)

1. Go to https://supabase.com
2. Sign up / Log in
3. Click "New Project"
4. Fill in:
   - **Name**: mamasafe
   - **Database Password**: (create a strong password - SAVE THIS!)
   - **Region**: Choose closest to Rwanda (e.g., Frankfurt, London)
5. Click "Create new project" (wait 2 minutes for setup)

## Step 2: Get Database Connection String

1. In Supabase dashboard, go to **Settings** → **Database**
2. Scroll to **Connection string** section
3. Select **URI** tab
4. Copy the connection string (looks like):
   ```
   postgresql://postgres:[YOUR-PASSWORD]@db.xxxxxxxxxxxxx.supabase.co:5432/postgres
   ```
5. Replace `[YOUR-PASSWORD]` with the password you created in Step 1

## Step 3: Update Backend Configuration

1. Open `backend/.env` file
2. Replace the `DATABASE_URL` line with your Supabase connection string:
   ```
   DATABASE_URL=postgresql://postgres:your-password@db.xxxxx.supabase.co:5432/postgres
   ```
3. Save the file

## Step 4: Create Database Tables

Run this command in your backend folder:
```bash
cd C:\Users\Djafari\Pictures\done\done\backend
python init_db.py
```

This creates all tables in Supabase (users, mothers, health_records, visits, referrals)

## Step 5: Migrate Your Data

Run the migration script:
```bash
python migrate_to_supabase.py
```

This copies all your existing data from SQLite to Supabase.

## Step 6: Test Your Backend

Start your server:
```bash
python start.py
```

Your backend now uses Supabase! Everything works exactly the same.

## Step 7: Access Your Database Online

1. Go to https://app.supabase.com
2. Select your project
3. Click **Table Editor** in sidebar
4. View all your data (users, mothers, referrals, etc.)

---

## ✅ What Changed:
- Database: SQLite → PostgreSQL (Supabase)
- Connection: Local file → Cloud database

## ✅ What Stayed the Same:
- All API endpoints
- All backend logic
- All models and relationships
- Your Flutter app (no changes needed)

---

## Troubleshooting

**Error: "DATABASE_URL not found"**
- Make sure `.env` file exists in backend folder
- Check that DATABASE_URL is set correctly

**Error: "Connection refused"**
- Check your internet connection
- Verify Supabase password is correct
- Make sure you replaced `[YOUR-PASSWORD]` in connection string

**Error: "Table already exists"**
- This is OK, tables were created successfully
- Continue with migration

---

## Backup

Your original SQLite database is still at:
```
C:\Users\Djafari\Pictures\done\done\backend\mamasafe.db
```

Keep this as backup until you confirm everything works!
