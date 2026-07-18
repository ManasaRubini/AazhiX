from fastapi import APIRouter, HTTPException, Query
from agents.fishzone_agent import FishZoneAgent

router = APIRouter(
    prefix="/api/fishzone",
    tags=["FishZone"]
)

fish_agent = FishZoneAgent()

@router.get("/")
def get_fishing_zone_advisory(
    lat: float = Query(...),
    lon: float = Query(...),
    species: str = Query("Any")
):

    if not (-90 <= lat <= 90) or not (-180 <= lon <= 180):
        raise HTTPException(status_code=400, detail="Invalid GPS coordinates.")

    try:
        return fish_agent.analyze_fishing_zone(lat, lon, species)

    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail=f"Agent Error: {str(e)}"
        )