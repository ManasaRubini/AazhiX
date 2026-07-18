from fastapi import APIRouter
from pydantic import BaseModel
from datetime import datetime

router = APIRouter(
    prefix="/api/sos",
    tags=["SOS"]
)

class SOSRequest(BaseModel):
    trigger: str = "manual"
    latitude: float | None = None
    longitude: float | None = None


@router.post("/")
def send_sos(data: SOSRequest):

    # simulate emergency processing
    return {
        "status": "SOS ACTIVATED",
        "trigger": data.trigger,
        "latitude": data.latitude or 10.78,
        "longitude": data.longitude or 79.23,
        "message": "Emergency signal generated successfully",
        "time": datetime.utcnow().isoformat(),
        "nearest_coast_guard": "Nagapattinam Coast Guard",
        "emergency_contacts_notified": True
    }