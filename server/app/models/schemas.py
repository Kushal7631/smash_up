from pydantic import BaseModel, Field
from datetime import date, time, datetime
from typing import Optional


# ──── Auth Models ────

class RegisterRequest(BaseModel):
    name: str = Field(..., min_length=1, description="User's display name")
    email: str = Field(..., description="User's email address")
    password: str = Field(..., min_length=4, description="User's password")


class LoginRequest(BaseModel):
    email: str = Field(..., description="User's email address")
    password: str = Field(..., description="User's password")


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
