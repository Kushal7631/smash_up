from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.database import create_pool, close_pool
from app.seed import seed_venues
from app.database import get_pool
from app.routers import venues, bookings, users, auth


@asynccontextmanager
async def lifespan(app: FastAPI):
    """Startup: create DB pool + seed data. Shutdown: close pool."""
    await create_pool()
    await seed_venues(get_pool())
    print("🚀 QuickSlot API ready")
    yield
    await close_pool()
    print("👋 QuickSlot API shutdown")


app = FastAPI(
    title="QuickSlot API",
    description="Sports slot booking API with concurrency-safe bookings",
    version="1.0.0",
    lifespan=lifespan,
)

# CORS — allow Flutter app from any origin during development
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register routers
app.include_router(auth.router)
app.include_router(venues.router)
app.include_router(bookings.router)
app.include_router(users.router)


@app.get("/", tags=["Health"])
async def health_check():
    return {"status": "ok", "service": "QuickSlot API"}
