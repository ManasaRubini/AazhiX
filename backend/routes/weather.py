from fastapi import APIRouter
from agents.weather_agent import get_weather

router = APIRouter()

@router.get("/weather")
def weather(city: str = "Chennai", lat: float | None = None, lon: float | None = None):
    return get_weather(location=city, lat=lat, lon=lon)