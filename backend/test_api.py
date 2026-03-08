import requests
import json

BASE_URL = "http://localhost:8000"

def test_server():
    print("🧪 Testing MamaSafe Backend...\n")
    
    # Test 1: Root endpoint
    print("1️⃣ Testing root endpoint...")
    try:
        response = requests.get(f"{BASE_URL}/")
        if response.status_code == 200:
            print("   ✅ Server is running!")
            print(f"   Response: {response.json()}\n")
        else:
            print(f"   ❌ Failed: {response.status_code}\n")
            return
    except Exception as e:
        print(f"   ❌ Server not running: {e}\n")
        print("   💡 Start the server first: python -m uvicorn main:app --reload\n")
        return
    
    # Test 2: Login with admin
    print("2️⃣ Testing admin login...")
    try:
        response = requests.post(
            f"{BASE_URL}/auth/login",
            json={"email": "admin@mamasafe.com", "password": "admin123"}
        )
        if response.status_code == 200:
            token = response.json()["access_token"]
            print("   ✅ Admin login successful!")
            print(f"   Token: {token[:50]}...\n")
            
            # Test 3: Get current user
            print("3️⃣ Testing get current user...")
            headers = {"Authorization": f"Bearer {token}"}
            response = requests.get(f"{BASE_URL}/auth/me", headers=headers)
            if response.status_code == 200:
                user = response.json()
                print("   ✅ User info retrieved!")
                print(f"   Name: {user['name']}")
                print(f"   Email: {user['email']}")
                print(f"   Role: {user['role']}\n")
            else:
                print(f"   ❌ Failed: {response.status_code}\n")
        else:
            print(f"   ❌ Login failed: {response.status_code}\n")
    except Exception as e:
        print(f"   ❌ Error: {e}\n")
    
    # Test 4: Prediction endpoint
    print("4️⃣ Testing ML prediction...")
    try:
        response = requests.post(
            f"{BASE_URL}/predict",
            json={
                "Age": 28,
                "SystolicBP": 120,
                "DiastolicBP": 80,
                "BS": 5.5,
                "BodyTemp": 37.0,
                "HeartRate": 75
            }
        )
        if response.status_code == 200:
            result = response.json()
            print("   ✅ Prediction successful!")
            print(f"   Risk Level: {result['risk_level']}\n")
        else:
            print(f"   ❌ Failed: {response.status_code}\n")
    except Exception as e:
        print(f"   ❌ Error: {e}\n")
    
    print("🎉 All tests completed!\n")
    print("📚 View full API docs at: http://localhost:8000/docs")

if __name__ == "__main__":
    test_server()
