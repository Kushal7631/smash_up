from fastapi import APIRouter, Depends
from app.database import get_pool
from app.services.auth_service import auth_service
from app.models.schemas import RegisterRequest, LoginRequest, UserResponse, UpdateProfileRequest
from app.utils.jwt_handler import create_token, verify_token

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/register", status_code=201)
async def register(body: RegisterRequest):
    """Register a new user. Returns user info + JWT token."""
    pool = get_pool()
    user = await auth_service.register(pool, body.name, body.email, body.password)
    token = create_token(user["id"], user["email"])
    return {"user": user, "token": token}


@router.post("/login")
async def login(body: LoginRequest):
    """Login with email and password. Returns user info + JWT token."""
    pool = get_pool()
    user = await auth_service.login(pool, body.email, body.password)
    token = create_token(user["id"], user["email"])
    return {"user": user, "token": token}


@router.get("/profile", response_model=UserResponse)
async def get_profile(user_id: int = Depends(verify_token)):
    """Get the current user's profile. Requires Bearer token."""
    pool = get_pool()
    user = await auth_service.get_profile(pool, user_id)
    return user


@router.put("/profile", response_model=UserResponse)
async def update_profile(
    body: UpdateProfileRequest,
    user_id: int = Depends(verify_token),
):
    """Update the current user's profile. Requires Bearer token."""
    pool = get_pool()
    user = await auth_service.update_profile(pool, user_id, body.name, body.phone, body.bio, body.avatar)
    return user
