"""
Referral Decision Engine
Automatically determines severity and selects appropriate hospital for high-risk cases

Scoring System:
- Age ≥ 35: +1 point
- BP ≥ 140/90: +1 point
- Abnormal Blood Sugar: +1 point
- Heart Rate < 60 or > 110: +1 point
- Chronic Condition = YES: +1 point
- On Medication = YES: +1 point
- Allergies = YES: +1 point

Hospital Selection:
- Score 0-1 → Kibagabaga Level II Teaching Hospital
- Score 2-3 → Kacyiru District Hospital
- Score 4+ OR Critical Vitals → King Faisal Hospital Rwanda
"""
from models import SeverityLevel

# Hospital configuration for Gasabo District
GASABO_HOSPITALS = {
    "Critical": "King Faisal Hospital Rwanda",
    "Moderate": "Kacyiru District Hospital",
    "Lower": "Kibagabaga Level II Teaching Hospital"
}

def has_critical_vitals(systolic_bp, diastolic_bp, blood_sugar, heart_rate):
    """
    Check for critical vital signs that require immediate tertiary care
    
    Critical Vitals:
    - BP ≥ 160/110
    - Blood Sugar extremely high (≥15) or low (≤3)
    - HR > 130 or < 50
    """
    if systolic_bp >= 160 or diastolic_bp >= 110:
        return True
    if blood_sugar >= 15 or blood_sugar <= 3:
        return True
    if heart_rate > 130 or heart_rate < 50:
        return True
    return False

def calculate_severity_score(systolic_bp, diastolic_bp, blood_sugar, heart_rate, age, 
                            has_chronic_condition=False, on_medication=False, has_allergies=False):
    """
    Calculate severity score based on risk factors
    
    Returns: (score, reasons)
    """
    score = 0
    reasons = []
    
    # Age ≥ 35
    if age >= 35:
        score += 1
        reasons.append(f"Age {age} (≥35)")
    
    # BP ≥ 140/90
    if systolic_bp >= 140 or diastolic_bp >= 90:
        score += 1
        reasons.append(f"BP {systolic_bp}/{diastolic_bp} (≥140/90)")
    
    # Abnormal Blood Sugar (< 4 or > 7)
    if blood_sugar < 4 or blood_sugar > 7:
        score += 1
        reasons.append(f"Blood Sugar {blood_sugar} mmol/L (abnormal)")
    
    # Heart Rate < 60 or > 110
    if heart_rate < 60 or heart_rate > 110:
        score += 1
        reasons.append(f"Heart Rate {heart_rate} bpm (abnormal)")
    
    # Chronic Condition
    if has_chronic_condition:
        score += 1
        reasons.append("Has chronic condition")
    
    # On Medication
    if on_medication:
        score += 1
        reasons.append("Currently on medication")
    
    # Allergies
    if has_allergies:
        score += 1
        reasons.append("Has allergies")
    
    return score, reasons

def calculate_severity(systolic_bp, diastolic_bp, blood_sugar, body_temp, heart_rate, age,
                      has_chronic_condition=False, on_medication=False, has_allergies=False):
    """
    Calculate severity level based on scoring system
    
    Returns: SeverityLevel (CRITICAL, MODERATE, or LOWER)
    """
    # Check for critical vitals first
    if has_critical_vitals(systolic_bp, diastolic_bp, blood_sugar, heart_rate):
        return SeverityLevel.CRITICAL
    
    # Calculate score
    score, _ = calculate_severity_score(
        systolic_bp, diastolic_bp, blood_sugar, heart_rate, age,
        has_chronic_condition, on_medication, has_allergies
    )
    
    # Determine severity based on score
    if score >= 4:
        return SeverityLevel.CRITICAL
    elif score >= 2:
        return SeverityLevel.MODERATE
    else:
        return SeverityLevel.LOWER

def select_hospital(severity, district):
    """
    Select appropriate hospital based on severity and location
    
    Only works for Gasabo District (Kimironko Sector)
    """
    # Verify location is in Gasabo District
    if district.lower() != "gasabo":
        raise ValueError("Automatic hospital selection only available for Gasabo District")
    
    # Select hospital based on severity
    hospital = GASABO_HOSPITALS.get(severity.value)
    
    if not hospital:
        raise ValueError(f"No hospital configured for severity: {severity}")
    
    return hospital

def get_referral_recommendation(health_data, mother_location, mother_medical_history=None):
    """
    Main function: Get complete referral recommendation
    
    Args:
        health_data: dict with systolic_bp, diastolic_bp, blood_sugar, body_temp, heart_rate, age
        mother_location: dict with district, sector
        mother_medical_history: dict with has_chronic_condition, on_medication, has_allergies (optional)
    
    Returns:
        dict with severity, hospital, reasoning, score
    """
    # Extract medical history
    has_chronic_condition = False
    on_medication = False
    has_allergies = False
    
    if mother_medical_history:
        has_chronic_condition = mother_medical_history.get('has_chronic_condition', False)
        on_medication = mother_medical_history.get('on_medication', False)
        has_allergies = mother_medical_history.get('has_allergies', False)
    
    # Calculate severity
    severity = calculate_severity(
        systolic_bp=health_data['systolic_bp'],
        diastolic_bp=health_data['diastolic_bp'],
        blood_sugar=health_data['blood_sugar'],
        body_temp=health_data['body_temp'],
        heart_rate=health_data['heart_rate'],
        age=health_data['age'],
        has_chronic_condition=has_chronic_condition,
        on_medication=on_medication,
        has_allergies=has_allergies
    )
    
    # Calculate score and get reasons
    score, reasons = calculate_severity_score(
        systolic_bp=health_data['systolic_bp'],
        diastolic_bp=health_data['diastolic_bp'],
        blood_sugar=health_data['blood_sugar'],
        heart_rate=health_data['heart_rate'],
        age=health_data['age'],
        has_chronic_condition=has_chronic_condition,
        on_medication=on_medication,
        has_allergies=has_allergies
    )
    
    # Check for critical vitals
    critical = has_critical_vitals(
        health_data['systolic_bp'],
        health_data['diastolic_bp'],
        health_data['blood_sugar'],
        health_data['heart_rate']
    )
    
    # Select hospital
    hospital = select_hospital(severity, mother_location['district'])
    
    # Generate reasoning
    reasoning = _generate_reasoning(severity, score, reasons, critical)
    
    return {
        "severity": severity,
        "hospital": hospital,
        "reasoning": reasoning,
        "score": score,
        "critical_vitals": critical
    }

def _generate_reasoning(severity, score, reasons, critical_vitals):
    """Generate human-readable reasoning for the referral decision"""
    if critical_vitals:
        return f"CRITICAL VITALS DETECTED - Score: {score}/7. Factors: {'; '.join(reasons)}"
    else:
        return f"Severity Score: {score}/7. Factors: {'; '.join(reasons) if reasons else 'Multiple risk factors'}"
