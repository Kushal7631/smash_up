import asyncpg


class UserService:
    """Handles user-related queries."""

    async def get_user_bookings(self, pool: asyncpg.Pool, user_id: int) -> list[dict]:
        """Fetch all bookings for a user with venue and slot details."""
        async with pool.acquire() as conn:
            rows = await conn.fetch(
                """
                SELECT
                    b.id, b.slot_id, b.user_id,
                    b.created_at::text AS created_at,
                    v.name AS venue_name,
                    v.sport,
                    s.date::text AS date,
                    s.start_time::text AS start_time,
                    s.end_time::text AS end_time
                FROM bookings b
                JOIN slots s ON s.id = b.slot_id
                JOIN venues v ON v.id = s.venue_id
                WHERE b.user_id = $1
                ORDER BY s.date, s.start_time
                """,
                user_id,
            )
            return [dict(r) for r in rows]


user_service = UserService()
