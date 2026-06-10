import os


DATABASE_URL = os.getenv("DATABASE_URL", "postgresql://localhost:5432/quickslot")

# Parse components for asyncpg (it doesn't take a URL string directly)
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = int(os.getenv("DB_PORT", "5432"))
DB_NAME = os.getenv("DB_NAME", "quickslot")
DB_USER = os.getenv("DB_USER", os.getenv("USER", "postgres"))
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")

# Valid hardcoded users
VALID_USERS = ["user1", "user2", "user3"]

# Slot configuration
SLOT_START_HOUR = 6   # 6 AM
SLOT_END_HOUR = 22    # 10 PM
