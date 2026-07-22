from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter()

class FuelRequest(BaseModel):
    fuel_capacity: float
    current_fuel: float
    distance_km: float
    consumption_per_km: float
    sea_condition: str

@router.post("/optimize")
def optimize_fuel(data: FuelRequest):
    base_fuel_needed = data.distance_km * data.consumption_per_km

    sea_factor = {
        "calm": 1.0,
        "medium": 1.3,
        "rough": 1.7
    }

    factor = sea_factor.get(data.sea_condition.lower(), 1.3)
    adjusted_fuel = base_fuel_needed * factor
    remaining_fuel = data.current_fuel - adjusted_fuel

    if remaining_fuel < 0:
        status = "NOT SAFE"
    elif remaining_fuel < data.fuel_capacity * 0.2:
        status = "RETURN SOON"
    else:
        status = "SAFE TO GO"

    # Dynamic marine fuel pricing standard
    fuel_price_per_litre = 96.50
    cost = adjusted_fuel * fuel_price_per_litre

    if status == "NOT SAFE":
        recommendation = f"Fuel insufficient! Need {round(adjusted_fuel - data.current_fuel, 1)}L additional fuel for safe return."
    elif status == "RETURN SOON":
        recommendation = "Fuel level low after trip. Return to nearest harbor soon."
    else:
        recommendation = "Trip is safe. Maintain steady speed for optimal fuel consumption."

    return {
        "fuel_level": round((data.current_fuel / data.fuel_capacity) * 100, 2),
        "consumption": data.consumption_per_km,
        "cost": round(cost, 2),
        "sea_condition": data.sea_condition,
        "recommendation": recommendation,
        "status": status
    }