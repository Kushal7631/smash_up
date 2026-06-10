import asyncpg
from datetime import datetime
from app.seed import ensure_slots_for_date


class VenueService:
    """Handles venue and slot queries."""

    async def get_all_venues(self, pool: asyncpg.Pool) -> list[dict]:
        """Fetch all venues."""
        async with pool.acquire() as conn:
            rows = await conn.fetch("SELECT id, name, sport, location FROM venues ORDER BY id")
            return [dict(r) for r in rows]

    async def get_venue_by_id(self, pool: asyncpg.Pool, venue_id: int) -> dict | None:
        """Fetch a single venue."""
        async with pool.acquire() as conn:
            row = await conn.fetchrow("SELECT id, name, sport, location FROM venues WHERE id = $1", venue_id)
            return dict(row) if row else None

    async def get_slots_for_venue(self, pool: asyncpg.Pool, venue_id: int, date_str: str) -> list[dict]:
        """Fetch slots for a venue on a date, with booking status."""
        # Auto-generate slots for the date if they don't exist
        await ensure_slots_for_date(pool, venue_id, date_str)

        d = datetime.strptime(date_str, "%Y-%m-%d").date()

        async with pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT
                    s.id, s.venue_id,
                    s.date::text AS date,
                    s.start_time::text AS start_time,
                    s.end_time::text AS end_time,
                    CASE WHEN b.id IS NOT NULL THEN true ELSE false END AS is_booked,
                    b.user_id AS booked_by
                FROM slots s
                LEFT JOIN bookings b ON b.slot_id = s.id
                WHERE s.venue_id = $1 AND s.date = $2
                ORDER BY s.start_time
                """,
                venue_id, d,
            )
            return [dict(r) for r in rows]


venue_service = VenueService()
