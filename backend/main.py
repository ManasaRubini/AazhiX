import os
import uvicorn
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from routes.weather import router as weather_router
from routes.fishzone import router as fishzone_router
from routes.marine_doctor import router as marine_doctor_router
from routes.market import router as market_router
from routes.plastic import router as plastic_router
from routes.sos import router as sos_router
from routes.captain import router as captain_router
from routes.notifications import router as notifications_router
from routes import fuel

# Ensure uploads directory exists for file processing
os.makedirs("uploads", exist_ok=True)

app = FastAPI(
    title="AazhiX API",
    version="1.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(fuel.router, prefix="/fuel")
app.include_router(weather_router)
app.include_router(fishzone_router)
app.include_router(marine_doctor_router)
app.include_router(market_router)
app.include_router(plastic_router)
app.include_router(sos_router)
app.include_router(captain_router)
app.include_router(notifications_router)

@app.get("/")
def root():
    return {
        "message": "Welcome to AazhiX Backend",
        "status": "online"
    }

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8000))
    uvicorn.run("main:app", host="0.0.0.0", port=port)