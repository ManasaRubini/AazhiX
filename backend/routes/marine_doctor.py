from fastapi import APIRouter, UploadFile, File
import shutil

from agents.marine_doctor_agent import analyze_engine

router = APIRouter()


@router.post("/marine-doctor")
async def marine_doctor(file: UploadFile = File(...)):

    path = f"uploads/{file.filename}"

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    result = analyze_engine(path)

    if result["engine_status"] == "normal":
        return {
            "status": "Healthy",
            "confidence": 92,
            "recommendation": "Engine operating normally"
        }

    elif result["severity"] == "LOW":
        return {
            "status": "Minor Issue",
            "confidence": 85,
            "recommendation": "Inspect engine components during next maintenance."
        }

    elif result["severity"] == "MEDIUM":
        return {
            "status": "Warning",
            "confidence": 80,
            "recommendation": "Engine requires attention soon."
        }

    else:
        return {
            "status": "Critical",
            "confidence": 75,
            "recommendation": "Stop operation and service the engine immediately."
        }