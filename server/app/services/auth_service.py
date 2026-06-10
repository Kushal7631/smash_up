import asyncpg
import hashlib
from fastapi import HTTPException


def _hash_password(password: str) -> str:
    """Hash password using SHA-256. Simple but sufficient for this scope."""
    return hashlib.sha256(password.encode()).hexdigest()


def _verify_password(password: str, hashed: str) -> bool:
    """Verify password against stored hash."""
    return _hash_password(password) == hashed


class AuthService:
    """Handles user registration, login, and profile management."""

    async def register(self, pool: asyncpg.Pool, name: str, email: str, password: str) -> dict:
        """Register a new user."""
        async with pool.acquire() as conn:
            existing = await conn.fetchrow(
                "SELECT id FROM users WHERE email = $1", email.lower()
            )
            if existing:
                raise HTTPException(status_code=409, detail="Email already registered")

            hashed = _hash_password(password)
            row = await conn.fetchrow(
                """
                INSERT INTO users (name, email, password)
                VALUES ($1, $2, $3)
                RETURNING id, name, email, phone, bio, avatar
                """,
                name, email.lower(), hashed,
            )
            return dict(row)

    async def login(self, pool: asyncpg.Pool, email: str, password: str) -> dict:
        """Login with email and password."""
        async with pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT id, name, email, phone, bio, avatar, password FROM users WHERE email = $1",
                email.lower(),
            )
            if not row:
                raise HTTPException(status_code=401, detail="Invalid email or password")

            if not _verify_password(password, row["password"]):
                raise HTTPException(status_code=401, detail="Invalid email or password")

            return {"id": row["id"], "name": row["name"], "email": row["email"],
                    "phone": row["phone"], "bio": row["bio"], "avatar": row["avatar"]}

    async def get_profile(self, pool: asyncpg.Pool, user_id: int) -> dict:
        """Get user profile by ID."""
        async with pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT id, name, email, phone, bio, avatar FROM users WHERE id = $1",
                user_id,
            )
            if not row:
                raise HTTPException(status_code=404, detail="User not found")
            return dict(row)

    async def update_profile(self, pool: asyncpg.Pool, user_id: int,
                             name: str | None, phone: str | None,
                             bio: str | None, avatar: str | None) -> dict:
        """Update user profile fields."""
        async with pool.acquire() as conn:
            current = await conn.fetchrow(
                "SELECT id, name, email, phone, bio, avatar FROM users WHERE id = $1", user_id
            )
            if not current:
                raise HTTPException(status_code=404, detail="User not found")

            new_name = name if name is not None else current["name"]
            new_phone = phone if phone is not None else current["phone"]
            new_bio = bio if bio is not None else current["bio"]
            new_avatar = avatar if avatar is not None else current["avatar"]

            row = await conn.fetchrow(
                """
                UPDATE users SET name = $1, phone = $2, bio = $3, avatar = $4
                WHERE id = $5
                RETURNING id, name, email, phone, bio, avatar
                """,
                new_name, new_phone, new_bio, new_avatar, user_id,
            )
            return dict(row)


auth_service = AuthService()
