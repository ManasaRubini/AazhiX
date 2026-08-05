from fastapi import APIRouter
from pydantic import BaseModel
from agents.captain_agent import process_query

router = APIRouter(
    prefix="/api/captain",
    tags=["Captain AI"]
)

class CaptainQueryRequest(BaseModel):
    query: str
    latitude: float | None = None
    longitude: float | None = None

@router.post("/query")
def captain_voice_query(data: CaptainQueryRequest):
    return process_query(data.query, data.latitude, data.longitude)
