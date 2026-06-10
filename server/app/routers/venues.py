from fastapi import APIRouter, Query, HTTPException
from app.database import get_pool
from app.services.venue_service import venue_service
from app.models.schemas import VenueResponse, SlotResponse
from datetime import date

router = APIRouter(prefix="/venues", tags=["Venues"])


@router.get("", response_model=list[VenueResponse])
async def list_venues():
    """List all venues."""
    pool = get_pool()
    venues = await venue_service.get_all_venues(pool)
    return venues


@router.get("/{venue_id}/slots", response_model=list[SlotResponse])
async def get_venue_slots(
    venue_id: int,
    date: str = Query(..., description="Date in YYYY-MM-DD format", pattern=r"^\d{4}-\d{2}-\d{2}$"),
):
    """Get all slots for a venue on a specific date, with booking status."""
    pool = get_pool()

    # Check venue exists
    venue = await venue_service.get_venue_by_id(pool, venue_id)
    if not venue:
        raise HTTPException(status_code=404, detail="Venue not found")

    slots = await venue_service.get_slots_for_venue(pool, venue_id, date)
    return slots
