import requests
import json

BASE_URL = "http://127.0.0.1:8000"

# Test cases
test_cases = [
    {"name": "Low Risk", "data": {"Age": 23, "SystolicBP": 90, "DiastolicBP": 60, "BS": 7.01, "BodyTemp": 98, "HeartRate": 76}},
    {"name": "Mid Risk", "data": {"Age": 29, "SystolicBP": 90, "DiastolicBP": 70, "BS": 6.7, "BodyTemp": 98, "HeartRate": 80}},
    {"name": "High Risk", "data": {"Age": 25, "SystolicBP": 130, "DiastolicBP": 80, "BS": 15, "BodyTemp": 98, "HeartRate": 86}},
]

print("="*70)
print("TESTING /predict API ENDPOINT")
print("="*70)

for test in test_cases:
    print(f"\nTesting: {test['name']}")
    print(f"Input: {test['data']}")
    
    try:
        response = requests.post(f"{BASE_URL}/predict", json=test['data'])
        
        if response.status_code == 200:
            result = response.json()
            print(f"[OK] Prediction: {result['risk_level']}")
        else:
            print(f"[ERROR] Status: {response.status_code}")
            print(f"Response: {response.text}")
    except Exception as e:
        print(f"[ERROR] {e}")

print("\n" + "="*70)
print("API TEST COMPLETE")
print("="*70)
