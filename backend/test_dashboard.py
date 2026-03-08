"""
Test the admin dashboard endpoint directly
"""
import requests
import json

# Test without authentication first
print("\n" + "="*50)
print("TESTING ADMIN DASHBOARD ENDPOINT")
print("="*50 + "\n")

base_url = "http://localhost:8000"

# First, login as admin to get token
print("1. Logging in as admin...")
try:
    login_response = requests.post(
        f"{base_url}/auth/login",
        json={"email": "admin@mamasafe.rw", "password": "admin123"},
        headers={"Content-Type": "application/json"}
    )
    
    if login_response.status_code == 200:
        token = login_response.json()["access_token"]
        print(f"✅ Login successful! Token: {token[:20]}...")
    else:
        print(f"❌ Login failed: {login_response.status_code}")
        print(f"   Response: {login_response.text}")
        exit(1)
except Exception as e:
    print(f"❌ Error during login: {e}")
    exit(1)

# Now test the dashboard endpoint
print("\n2. Fetching admin dashboard...")
try:
    dashboard_response = requests.get(
        f"{base_url}/admin/dashboard",
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {token}"
        }
    )
    
    if dashboard_response.status_code == 200:
        data = dashboard_response.json()
        print("✅ Dashboard data retrieved successfully!\n")
        print(json.dumps(data, indent=2))
        
        print("\n" + "="*50)
        print("SUMMARY:")
        print("="*50)
        print(f"Total Mothers: {data.get('total_mothers', 0)}")
        print(f"High Risk: {data.get('high_risk', 0)}")
        print(f"Medium Risk: {data.get('medium_risk', 0)}")
        print(f"Low Risk: {data.get('low_risk', 0)}")
        print(f"Total Referrals: {data.get('total_referrals', 0)}")
        print(f"Pending Referrals: {data.get('pending_referrals', 0)}")
        print(f"Active CHWs: {data.get('active_chws', 0)}")
        print(f"Active Hospitals: {data.get('active_hospitals', 0)}")
        print(f"Locations: {len(data.get('locations', []))}")
        
        if data.get('total_mothers', 0) == 0:
            print("\n⚠️  WARNING: All values are zero!")
            print("This means the backend is working but returning zero values.")
            print("Check if the database queries are correct.")
        else:
            print("\n✅ Backend is working correctly with real data!")
            
    else:
        print(f"❌ Dashboard request failed: {dashboard_response.status_code}")
        print(f"   Response: {dashboard_response.text}")
except Exception as e:
    print(f"❌ Error fetching dashboard: {e}")

print("\n" + "="*50 + "\n")
