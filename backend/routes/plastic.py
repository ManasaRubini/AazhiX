from fastapi import APIRouter, UploadFile, File
import shutil

from agents.plastic_agent import analyze_plastic

router = APIRouter()

@router.post("/plastic")
async def plastic_detection(file: UploadFile = File(...)):

    path = f"uploads/{file.filename}"

    with open(path, "wb") as buffer:
        shutil.copyfileobj(file.file, buffer)

    return analyze_plastic(path)