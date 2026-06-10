from fastapi import APIRouter
from app.database import get_pool
from app.services.user_service import user_service
from app.models.schemas import BookingResponse

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/{user_id}/bookings", response_model=list[BookingResponse])
async def get_user_bookings(user_id: int):
    """Get all bookings for a user."""
    pool = get_pool()
    bookings = await user_service.get_user_bookings(pool, user_id)
    return bookings
