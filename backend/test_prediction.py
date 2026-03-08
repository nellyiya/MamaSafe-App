import sys
import os
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

import joblib
import pandas as pd

# Load models
MODEL_DIR = os.path.join(os.path.dirname(__file__), "model")
print(f"Loading models from: {MODEL_DIR}\n")

rf_model = joblib.load(os.path.join(MODEL_DIR, "rf_model.pkl"))
scaler = joblib.load(os.path.join(MODEL_DIR, "scaler.pkl"))
label_encoder = joblib.load(os.path.join(MODEL_DIR, "label_encoder.pkl"))

print("[OK] Models loaded successfully!\n")

# Test cases from your data
test_cases = [
    # Low risk examples
    {"Age": 25, "SystolicBP": 120, "DiastolicBP": 80, "BS": 7.0, "BodyTemp": 98, "HeartRate": 70, "Expected": "low risk"},
    {"Age": 23, "SystolicBP": 90, "DiastolicBP": 60, "BS": 7.01, "BodyTemp": 98, "HeartRate": 76, "Expected": "low risk"},
    
    # Mid risk examples
    {"Age": 29, "SystolicBP": 90, "DiastolicBP": 70, "BS": 6.7, "BodyTemp": 98, "HeartRate": 80, "Expected": "mid risk"},
    {"Age": 23, "SystolicBP": 130, "DiastolicBP": 70, "BS": 7.01, "BodyTemp": 98, "HeartRate": 78, "Expected": "mid risk"},
    
    # High risk examples
    {"Age": 25, "SystolicBP": 130, "DiastolicBP": 80, "BS": 15, "BodyTemp": 98, "HeartRate": 86, "Expected": "high risk"},
    {"Age": 35, "SystolicBP": 140, "DiastolicBP": 90, "BS": 13, "BodyTemp": 98, "HeartRate": 70, "Expected": "high risk"},
]

print("="*70)
print("TESTING PREDICTIONS")
print("="*70)

for i, test in enumerate(test_cases, 1):
    # Prepare input
    input_df = pd.DataFrame([{
        "Age": test["Age"],
        "SystolicBP": test["SystolicBP"],
        "DiastolicBP": test["DiastolicBP"],
        "BS": test["BS"],
        "BodyTemp": test["BodyTemp"],
        "HeartRate": test["HeartRate"]
    }])
    
    # Make prediction
    scaled_input = scaler.transform(input_df)
    prediction = rf_model.predict(scaled_input)[0]
    risk_level = label_encoder.inverse_transform([prediction])[0]
    
    # Display result
    print(f"\nTest {i}:")
    print(f"  Input: Age={test['Age']}, BP={test['SystolicBP']}/{test['DiastolicBP']}, BS={test['BS']}, Temp={test['BodyTemp']}, HR={test['HeartRate']}")
    print(f"  Expected: {test['Expected']}")
    print(f"  Predicted: {risk_level}")
    print(f"  Status: {'[OK]' if risk_level.lower() == test['Expected'] else '[MISMATCH]'}")

print("\n" + "="*70)
print("PREDICTION TEST COMPLETE")
print("="*70)
