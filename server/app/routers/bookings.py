from fastapi import APIRouter, Header, HTTPException
from app.database import get_pool
from app.services.booking_service import booking_service
from app.models.schemas import BookingCreateRequest, BookingResponse, MessageResponse

router = APIRouter(prefix="/bookings", tags=["Bookings"])


@router.post("", response_model=BookingResponse, status_code=201)
async def create_booking(
    body: BookingCreateRequest,
    x_user_id: int = Header(..., alias="X-User-Id"),
):
    """Book a slot. Concurrency-safe — only one user can book a slot."""
    pool = get_pool()
    booking = await booking_service.create_booking(pool, body.slot_id, x_user_id)
    return booking


@router.delete("/{booking_id}", response_model=MessageResponse)
async def cancel_booking(
    booking_id: int,
    x_user_id: int = Header(..., alias="X-User-Id"),
):
    """Cancel a booking. Only the booking owner can cancel."""
    pool = get_pool()
    result = await booking_service.cancel_booking(pool, booking_id, x_user_id)
    return result
