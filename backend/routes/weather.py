from fastapi import APIRouter
from agents.weather_agent import get_weather

router = APIRouter()

@router.get("/weather")
def weather(city: str = "Chennai"):
    return get_weather(city)