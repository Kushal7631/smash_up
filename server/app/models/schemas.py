from pydantic import BaseModel, Field, field_validator
from datetime import date, time, datetime
from typing import Optional
import re


# ──── Auth Models ────

class RegisterRequest(BaseModel):
    name: str = Field(..., min_length=1, description="User's display name")
    email: str = Field(..., description="User's email address")
    password: str = Field(..., min_length=6, description="User's password")

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, v):
            raise ValueError('Please enter a valid email address (e.g. user@example.com)')
        return v.lower()

    @field_validator('password')
    @classmethod
    def validate_password(cls, v: str) -> str:
        if len(v) < 6:
            raise ValueError('Password must be at least 6 characters')
        if not re.search(r'[A-Z]', v):
            raise ValueError('Password must contain at least one uppercase letter')
        if not re.search(r'[a-z]', v):
            raise ValueError('Password must contain at least one lowercase letter')
        if not re.search(r'[0-9]', v):
            raise ValueError('Password must contain at least one number')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>]', v):
            raise ValueError('Password must contain at least one special character')
        return v


class LoginRequest(BaseModel):
    email: str = Field(..., description="User's email address")
    password: str = Field(..., description="User's password")

    @field_validator('email')
    @classmethod
    def validate_email(cls, v: str) -> str:
        pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(pattern, v):
            raise ValueError('Please enter a valid email address')
        return v.lower()


class UserResponse(BaseModel):
    id: int
    name: str
    email: str
    phone: str = ''
    bio: str = ''
    avatar: str = '🏸'


class UpdateProfileRequest(BaseModel):
    name: Optional[str] = None
    phone: Optional[str] = None
    bio: Optional[str] = None
    avatar: Optional[str] = None


# ──── Request Models ────

class BookingCreateRequest(BaseModel):
    slot_id: int = Field(..., description="ID of the slot to book")


# ──── Response Models ────

class VenueResponse(BaseModel):
    id: int
    name: str
    sport: str
    location: str


class SlotResponse(BaseModel):
    id: int
    venue_id: int
    date: str
    start_time: str
    end_time: str
    is_booked: bool
    booked_by: Optional[int] = None


class BookingResponse(BaseModel):
    id: int
    slot_id: int
    user_id: int
    created_at: str
    venue_name: Optional[str] = None
    sport: Optional[str] = None
    date: Optional[str] = None
    start_time: Optional[str] = None
    end_time: Optional[str] = None


class MessageResponse(BaseModel):
    message: str


class ErrorResponse(BaseModel):
    detail: str
