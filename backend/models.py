from sqlalchemy import Column, Integer, String, Float, DateTime, Boolean, ForeignKey, Enum as SQLEnum
from sqlalchemy.orm import relationship
from datetime import datetime
import enum
from database import Base

class UserRole(str, enum.Enum):
    ADMIN = "Admin"
    CHW = "CHW"
    HEALTHCARE_PRO = "HealthcarePro"

class UserStatus(str, enum.Enum):
    PENDING = "Pending"
    ACTIVE = "Active"
    SUSPENDED = "Suspended"

class ReferralStatus(str, enum.Enum):
    PENDING = "Pending"
    RECEIVED = "Received"
    APPOINTMENT_SCHEDULED = "Appointment Scheduled"
    EMERGENCY_CARE_REQUIRED = "Emergency Care Required"
    COMPLETED = "Completed"

class SeverityLevel(str, enum.Enum):
    CRITICAL = "Critical"
    MODERATE = "Moderate"
    LOWER = "Lower"

class User(Base):
    __tablename__ = "users"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    email = Column(String, unique=True, index=True, nullable=False)
    phone = Column(String, nullable=False)
    password_hash = Column(String, nullable=False)
    role = Column(SQLEnum(UserRole), nullable=False)
    
    # CHW specific fields
    district = Column(String)
    sector = Column(String)
    cell = Column(String)  # Assigned cell(s) - comma separated if multiple
    village = Column(String)
    
    # Hospital specific fields
    facility = Column(String)  # Hospital name
    
    language_preference = Column(String, default="en")
    theme_preference = Column(String, default="light")
    is_approved = Column(Boolean, default=False)
    status = Column(SQLEnum(UserStatus), default=UserStatus.PENDING)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    mothers = relationship("Mother", back_populates="chw", foreign_keys="Mother.created_by_chw_id")
    visits = relationship("Visit", back_populates="chw")
    referrals_created = relationship("Referral", back_populates="chw", foreign_keys="Referral.chw_id")
    referrals_received = relationship("Referral", back_populates="healthcare_pro", foreign_keys="Referral.healthcare_pro_id")

class Mother(Base):
    __tablename__ = "mothers"
    
    id = Column(Integer, primary_key=True, index=True)
    name = Column(String, nullable=False)
    age = Column(Integer, nullable=False)
    phone = Column(String, nullable=False)
    province = Column(String, nullable=False)
    district = Column(String, nullable=False)
    sector = Column(String, nullable=False)
    cell = Column(String, nullable=False)
    village = Column(String, nullable=False)
    pregnancy_start_date = Column(DateTime, nullable=False)
    due_date = Column(DateTime, nullable=False)
    created_by_chw_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    current_risk_level = Column(String, default="Not Predicted")
    
    # Medical history fields
    has_allergies = Column(Boolean, default=False)
    has_chronic_condition = Column(Boolean, default=False)
    on_medication = Column(Boolean, default=False)
    
    created_at = Column(DateTime, default=datetime.utcnow)
    
    chw = relationship("User", back_populates="mothers", foreign_keys=[created_by_chw_id])
    health_records = relationship("HealthRecord", back_populates="mother")
    visits = relationship("Visit", back_populates="mother")
    referrals = relationship("Referral", back_populates="mother")
    
    @property
    def hasScheduledAppointment(self):
        """Check if mother has any scheduled appointment"""
        from sqlalchemy.orm import object_session
        
        session = object_session(self)
        if not session:
            return False
        
        try:
            from sqlalchemy import text
            result = session.execute(
                text("SELECT COUNT(*) FROM referrals WHERE mother_id = :mother_id AND status = 'APPOINTMENT_SCHEDULED'"),
                {"mother_id": self.id}
            ).scalar()
            return result > 0
        except:
            return False

class HealthRecord(Base):
    __tablename__ = "health_records"
    
    id = Column(Integer, primary_key=True, index=True)
    mother_id = Column(Integer, ForeignKey("mothers.id"), nullable=False)
    age = Column(Integer, nullable=False)
    systolic_bp = Column(Integer, nullable=False)
    diastolic_bp = Column(Integer, nullable=False)
    blood_sugar = Column(Float, nullable=False)
    body_temp = Column(Float, nullable=False)
    heart_rate = Column(Integer, nullable=False)
    risk_level = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    mother = relationship("Mother", back_populates="health_records")

class Visit(Base):
    __tablename__ = "visits"
    
    id = Column(Integer, primary_key=True, index=True)
    mother_id = Column(Integer, ForeignKey("mothers.id"), nullable=False)
    chw_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    visit_date = Column(DateTime, default=datetime.utcnow)
    next_visit_date = Column(DateTime)
    notes = Column(String)
    completed = Column(Boolean, default=True)
    created_at = Column(DateTime, default=datetime.utcnow)
    
    mother = relationship("Mother", back_populates="visits")
    chw = relationship("User", back_populates="visits")

class Referral(Base):
    __tablename__ = "referrals"
    
    id = Column(Integer, primary_key=True, index=True)
    mother_id = Column(Integer, ForeignKey("mothers.id"), nullable=False)
    chw_id = Column(Integer, ForeignKey("users.id"), nullable=False)
    healthcare_pro_id = Column(Integer, ForeignKey("users.id"))
    hospital = Column(String, nullable=False)
    severity = Column(SQLEnum(SeverityLevel))
    notes = Column(String)
    diagnosis = Column(String)
    treatment_notes = Column(String)
    status = Column(SQLEnum(ReferralStatus), default=ReferralStatus.PENDING)
    
    # Timestamps for performance tracking
    risk_detected_time = Column(DateTime)
    chw_confirmed_time = Column(DateTime)
    hospital_received_time = Column(DateTime)
    created_at = Column(DateTime, default=datetime.utcnow)
    completed_at = Column(DateTime)
    
    # Appointment fields
    appointment_date = Column(DateTime)
    appointment_time = Column(String)
    department = Column(String)
    
    mother = relationship("Mother", back_populates="referrals")
    chw = relationship("User", back_populates="referrals_created", foreign_keys=[chw_id])
    healthcare_pro = relationship("User", back_populates="referrals_received", foreign_keys=[healthcare_pro_id])
