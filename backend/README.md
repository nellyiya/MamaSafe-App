# MamaSafe Backend API

Complete FastAPI backend for MamaSafe maternal health monitoring system.

## Features

✅ User Authentication (JWT)
✅ Role-Based Access Control (Admin, CHW, Healthcare Professional)
✅ User Approval System
✅ Mother Registration & Management
✅ Health Records & Risk Prediction
✅ Visit Tracking
✅ Referral System
✅ Dashboard Analytics
✅ Risk Heatmap
✅ Performance Metrics

## Setup

### 1. Install Dependencies

```bash
pip install -r requirements.txt
```

### 2. Configure Environment

Copy `.env.example` to `.env` and update:

```bash
cp .env.example .env
```

For SQLite (development):
```
DATABASE_URL=sqlite:///./mamasafe.db
```

For PostgreSQL (production):
```
DATABASE_URL=postgresql://user:password@localhost:5432/mamasafe
```

### 3. Initialize Database

```bash
python init_db.py
```

This creates:
- All database tables
- Default admin user (admin@mamasafe.com / admin123)

### 4. Run Server

```bash
cd api
uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
- `POST /auth/login` - Login and get JWT token
- `GET /auth/me` - Get current user info

### Admin
- `GET /admin/users/pending` - Get pending users
- `PUT /admin/users/{id}/approve` - Approve user
- `PUT /admin/users/{id}/reject` - Reject user
- `GET /admin/dashboard` - Admin dashboard stats
- `GET /admin/risk-heatmap` - Risk distribution by location

### Mothers
- `POST /mothers` - Register pregnant woman
- `GET /mothers` - List all mothers (filtered by CHW)
- `GET /mothers/{id}` - Get mother details

### Health Records
- `POST /health-records` - Create health record
- `GET /health-records/{mother_id}` - Get mother's health history

### Visits
- `POST /visits` - Record visit
- `GET /visits/due-today` - Get today's visits
- `GET /visits/overdue` - Get overdue visits

### Referrals
- `POST /referrals` - Create referral
- `GET /referrals/incoming` - Get incoming referrals (Healthcare Pro)
- `PUT /referrals/{id}` - Update referral status

### Dashboards
- `GET /dashboard/chw` - CHW dashboard stats
- `GET /dashboard/healthcare-pro` - Healthcare professional stats

### Prediction
- `POST /predict` - Predict maternal risk level

## Testing

Access API documentation at: http://localhost:8000/docs

## Default Credentials

**Admin:**
- Email: admin@mamasafe.com
- Password: admin123

## Security Notes

⚠️ Change SECRET_KEY in production
⚠️ Use strong passwords
⚠️ Enable HTTPS in production
⚠️ Update CORS settings for production
