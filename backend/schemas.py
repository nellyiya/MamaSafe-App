from pydantic import BaseModel, EmailStr
from datetime import datetime
from typing import Optional
from models import UserRole, UserStatus, ReferralStatus, SeverityLevel

# Auth Schemas
class UserRegister(BaseModel):
    name: str
    email: EmailStr
    phone: str
    password: str
    role: UserRole
    
    # CHW specific fields
    district: Optional[str] = None
    sector: Optional[str] = None
    cell: Optional[str] = None
    village: Optional[str] = None
    
    # Hospital specific fields
    facility: Optional[str] = None

class UserLogin(BaseModel):
    email: EmailStr
    password: str

class Token(BaseModel):
    access_token: str
    token_type: str

class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    phone: str
    role: UserRole
    district: Optional[str]
    sector: Optional[str]
    village: Optional[str]
    facility: Optional[str]
    is_approved: bool
    status: UserStatus
    created_at: datetime
    
    class Config:
        from_attributes = True

# Mother Schemas
class MotherCreate(BaseModel):
    name: str
    age: int
    phone: str
    province: str
    district: str
    sector: str
    cell: str
    village: str
    pregnancy_start_date: datetime
    due_date: datetime
    has_allergies: Optional[bool] = False
    has_chronic_condition: Optional[bool] = False
    on_medication: Optional[bool] = False

class MotherResponse(BaseModel):
    id: int
    name: str
    age: int
    phone: str
    province: str
    district: str
    sector: str
    cell: str
    village: str
    pregnancy_start_date: datetime
    due_date: datetime
    created_by_chw_id: int
    current_risk_level: str
    has_allergies: bool
    has_chronic_condition: bool
    on_medication: bool
    created_at: datetime
    hasScheduledAppointment: bool
    
    class Config:
        from_attributes = True

# Health Record Schemas
class HealthRecordCreate(BaseModel):
    mother_id: int
    age: int
    systolic_bp: int
    diastolic_bp: int
    blood_sugar: float
    body_temp: float
    heart_rate: int
    risk_level: str

class HealthRecordResponse(BaseModel):
    id: int
    mother_id: int
    age: int
    systolic_bp: int
    diastolic_bp: int
    blood_sugar: float
    body_temp: float
    heart_rate: int
    risk_level: str
    created_at: datetime
    
    class Config:
        from_attributes = True

# Visit Schemas
class VisitCreate(BaseModel):
    mother_id: int
    next_visit_date: Optional[datetime] = None
    notes: Optional[str] = None

class VisitResponse(BaseModel):
    id: int
    mother_id: int
    chw_id: int
    visit_date: datetime
    next_visit_date: Optional[datetime]
    notes: Optional[str]
    completed: bool
    created_at: datetime
    
    class Config:
        from_attributes = True

# Referral Schemas
class ReferralCreate(BaseModel):
    mother_id: int
    hospital: str
    severity: Optional[SeverityLevel] = None
    notes: Optional[str] = None
    risk_detected_time: Optional[datetime] = None

class ReferralUpdate(BaseModel):
    healthcare_pro_id: Optional[int] = None
    diagnosis: Optional[str] = None
    treatment_notes: Optional[str] = None
    status: Optional[ReferralStatus] = None
    hospital_received_time: Optional[datetime] = None
    appointment_date: Optional[datetime] = None
    appointment_time: Optional[str] = None
    department: Optional[str] = None

class ReferralResponse(BaseModel):
    id: int
    mother_id: int
    chw_id: int
    healthcare_pro_id: Optional[int]
    hospital: str
    severity: Optional[SeverityLevel]
    notes: Optional[str]
    diagnosis: Optional[str]
    treatment_notes: Optional[str]
    status: ReferralStatus
    risk_detected_time: Optional[datetime]
    chw_confirmed_time: Optional[datetime]
    hospital_received_time: Optional[datetime]
    created_at: datetime
    completed_at: Optional[datetime]
    appointment_date: Optional[datetime]
    appointment_time: Optional[str]
    department: Optional[str]
    
    class Config:
        from_attributes = True

# Prediction Schema
class PregnancyInput(BaseModel):
    Age: int
    SystolicBP: int
    DiastolicBP: int
    BS: float
    BodyTemp: float
    HeartRate: int
