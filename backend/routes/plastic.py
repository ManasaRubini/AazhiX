from fastapi import APIRouter, UploadFile, File
import shutil
import os
from agents.plastic_agent import analyze_plastic

router = APIRouter()

@router.post("/plastic")
async def plastic_detection(file: UploadFile = File(...)):
    os.makedirs("uploads", exist_ok=True)
    path = f"uploads/{file.filename}"

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    try:
        return analyze_plastic(path)
    except Exception as e:
        print("Plastic detection error:", e)
        return {
            "plastic_detected": False,
            "pollution_level": "LOW",
            "detections": []
        }