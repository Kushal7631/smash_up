import os
import asyncpg
import ssl


pool: asyncpg.Pool | None = None

# Use DATABASE_URL if available (Render), otherwise build from components
DATABASE_URL = os.getenv("DATABASE_URL")


async def create_pool():
    """Create the asyncpg connection pool and initialize schema."""
    global pool

    if DATABASE_URL:
        # Production: use DATABASE_URL directly (Render provides this)
        # Render URLs start with postgres:// but asyncpg needs postgresql://
        dsn = DATABASE_URL.replace("postgres://", "postgresql://", 1)
        ssl_ctx = ssl.create_default_context()
        ssl_ctx.check_hostname = False
        ssl_ctx.verify_mode = ssl.CERT_NONE
        pool = await asyncpg.create_pool(dsn=dsn, min_size=2, max_size=10, ssl=ssl_ctx)
    else:
        # Local development: use individual components
        from app.config import DB_HOST, DB_PORT, DB_NAME, DB_USER, DB_PASSWORD
        pool = await asyncpg.create_pool(
            host=DB_HOST,
            port=DB_PORT,
            database=DB_NAME,
            user=DB_USER,
            password=DB_PASSWORD if DB_PASSWORD else None,
            min_size=2,
            max_size=10,
        )

    # Create tables on startup
    async with pool.acquire() as conn:
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS users (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                email TEXT NOT NULL UNIQUE,
                password TEXT NOT NULL,
                phone TEXT DEFAULT '',
                bio TEXT DEFAULT '',
                avatar TEXT DEFAULT '🏸',
                created_at TIMESTAMPTZ DEFAULT NOW()
            );
        """)
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS venues (
                id SERIAL PRIMARY KEY,
                name TEXT NOT NULL,
                sport TEXT NOT NULL,
                location TEXT NOT NULL
            );
        """)
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS slots (
                id SERIAL PRIMARY KEY,
                venue_id INT NOT NULL REFERENCES venues(id),
                date DATE NOT NULL,
                start_time TIME NOT NULL,
                end_time TIME NOT NULL,
                UNIQUE(venue_id, date, start_time)
            );
        """)
        await conn.execute("""
            CREATE TABLE IF NOT EXISTS bookings (
                id SERIAL PRIMARY KEY,
                slot_id INT NOT NULL UNIQUE REFERENCES slots(id),
                user_id INT NOT NULL REFERENCES users(id),
                created_at TIMESTAMPTZ DEFAULT NOW()
            );
        """)


async def close_pool():
    """Close the connection pool."""
    global pool
    if pool:
        await pool.close()
        pool = None


def get_pool() -> asyncpg.Pool:
    """Get the current connection pool."""
    if pool is None:
        raise RuntimeError("Database pool not initialized")
    return pool
