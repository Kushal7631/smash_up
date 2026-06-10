from fastapi import APIRouter, Depends
from app.database import get_pool
from app.services.user_service import user_service
from app.models.schemas import BookingResponse
from app.utils.jwt_handler import verify_token

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me/bookings", response_model=list[BookingResponse])
async def get_my_bookings(user_id: int = Depends(verify_token)):
    """Get all bookings for the authenticated user. Requires Bearer token."""
    pool = get_pool()
    bookings = await user_service.get_user_bookings(pool, user_id)
    return bookings
