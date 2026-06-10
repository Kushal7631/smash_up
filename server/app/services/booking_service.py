import asyncpg
from fastapi import HTTPException


class BookingService:
    """Handles booking creation and cancellation with concurrency safety."""

    async def create_booking(self, pool: asyncpg.Pool, slot_id: int, user_id: int) -> dict:
        """
        Book a slot for a user.
        Uses SELECT FOR UPDATE to lock the row, preventing double-booking.
        """
        async with pool.acquire() as conn:
            async with conn.transaction():
                # 1. Lock the slot row — blocks other concurrent transactions
                slot = await conn.fetchrow(
                    "SELECT id FROM slots WHERE id = $1 FOR UPDATE",
                    slot_id,
                )
                if not slot:
                    raise HTTPException(status_code=404, detail="Slot not found")

                # 2. Check if already booked
                existing = await conn.fetchrow(
                    "SELECT id, user_id FROM bookings WHERE slot_id = $1",
                    slot_id,
                )
                if existing:
                    raise HTTPException(status_code=409, detail="Slot already booked")

                # 3. Create the booking
                row = await conn.fetchrow(
                    """
                    INSERT INTO bookings (slot_id, user_id)
                    VALUES ($1, $2)
                    RETURNING id, slot_id, user_id, created_at::text AS created_at
                    """,
                    slot_id, user_id,
                )
                return dict(row)

    async def cancel_booking(self, pool: asyncpg.Pool, booking_id: int, user_id: int) -> dict:
        """Cancel a booking. Only the owner can cancel."""
        async with pool.acquire() as conn:
            # Fetch the booking
            booking = await conn.fetchrow(
                "SELECT id, slot_id, user_id FROM bookings WHERE id = $1",
                booking_id,
            )
            if not booking:
                raise HTTPException(status_code=404, detail="Booking not found")

            if booking["user_id"] != user_id:
                raise HTTPException(status_code=403, detail="Not authorized to cancel this booking")

            await conn.execute("DELETE FROM bookings WHERE id = $1", booking_id)
            return {"message": "Booking cancelled successfully"}


booking_service = BookingService()
