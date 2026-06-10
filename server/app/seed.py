import asyncpg
from datetime import date, time, datetime
from app.config import SLOT_START_HOUR, SLOT_END_HOUR


VENUES = [
    {"name": "City Badminton Arena", "sport": "Badminton", "location": "MG Road, Sector 14"},
    {"name": "Green Turf Ground", "sport": "Football", "location": "Sports Complex, Whitefield"},
    {"name": "Indoor Sports Complex", "sport": "Badminton", "location": "HSR Layout, 5th Main"},
    {"name": "Riverside Cricket Turf", "sport": "Cricket", "location": "River Park, Indiranagar"},
]


async def seed_venues(pool: asyncpg.Pool):
    """Seed venues if table is empty."""
    async with pool.acquire() as conn:
        count = await conn.fetchval("SELECT COUNT(*) FROM venues")
        if count > 0:
            return

        for venue in VENUES:
            await conn.execute(
                "INSERT INTO venues (name, sport, location) VALUES ($1, $2, $3)",
                venue["name"], venue["sport"], venue["location"],
            )
        print(f"✅ Seeded {len(VENUES)} venues")


def _parse_date(date_str: str) -> date:
    """Parse YYYY-MM-DD string into datetime.date."""
    return datetime.strptime(date_str, "%Y-%m-%d").date()


async def ensure_slots_for_date(pool: asyncpg.Pool, venue_id: int, date_str: str):
    """Generate hourly slots for a venue on a date if they don't exist yet."""
    d = _parse_date(date_str)

    async with pool.acquire() as conn:
        existing = await conn.fetchval(
            "SELECT COUNT(*) FROM slots WHERE venue_id = $1 AND date = $2",
            venue_id, d,
        )
        if existing > 0:
            return

        for hour in range(SLOT_START_HOUR, SLOT_END_HOUR):
            start = time(hour, 0)
            end = time(hour + 1, 0)
            await conn.execute(
                "INSERT INTO slots (venue_id, date, start_time, end_time) VALUES ($1, $2, $3, $4)",
                venue_id, d, start, end,
            )
