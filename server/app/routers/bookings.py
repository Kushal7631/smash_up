from fastapi import APIRouter, Depends
from app.database import get_pool
from app.services.booking_service import booking_service
from app.models.schemas import BookingCreateRequest, BookingResponse, MessageResponse
from app.utils.jwt_handler import verify_token

router = APIRouter(prefix="/bookings", tags=["Bookings"])


@router.post("", response_model=BookingResponse, status_code=201)
async def create_booking(
    body: BookingCreateRequest,
    user_id: int = Depends(verify_token),
):
    """Book a slot. Requires Bearer token. Concurrency-safe."""
    pool = get_pool()
    booking = await booking_service.create_booking(pool, body.slot_id, user_id)
    return booking


@router.delete("/{booking_id}", response_model=MessageResponse)
async def cancel_booking(
    booking_id: int,
    user_id: int = Depends(verify_token),
):
    """Cancel a booking. Requires Bearer token. Only the owner can cancel."""
    pool = get_pool()
    result = await booking_service.cancel_booking(pool, booking_id, user_id)
    return result
