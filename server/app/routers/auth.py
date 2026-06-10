from fastapi import APIRouter, Header
from app.database import get_pool
from app.services.auth_service import auth_service
from app.models.schemas import RegisterRequest, LoginRequest, UserResponse, UpdateProfileRequest

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", response_model=UserResponse, status_code=201)
async def register(body: RegisterRequest):
    """Register a new user with name, email, and password."""
    pool = get_pool()
    user = await auth_service.register(pool, body.name, body.email, body.password)
    return user


@router.post("/login", response_model=UserResponse)
async def login(body: LoginRequest):
    """Login with email and password. Returns user info."""
    pool = get_pool()
    user = await auth_service.login(pool, body.email, body.password)
    return user


@router.get("/profile", response_model=UserResponse)
async def get_profile(x_user_id: int = Header(..., alias="X-User-Id")):
    """Get the current user's profile."""
    pool = get_pool()
    user = await auth_service.get_profile(pool, x_user_id)
    return user


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    body: UpdateProfileRequest,
    x_user_id: int = Header(..., alias="X-User-Id"),
):
    """Update the current user's profile (name, phone, bio, avatar)."""
    pool = get_pool()
    user = await auth_service.update_profile(pool, x_user_id, body.name, body.phone, body.bio, body.avatar)
    return user
