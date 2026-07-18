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

    factor = sea_factor.get(data.sea_condition, 1.3)

    adjusted_fuel = base_fuel_needed * factor
    remaining_fuel = data.current_fuel - adjusted_fuel

    # status
    if remaining_fuel < 0:
        status = "NOT SAFE"
    elif remaining_fuel < data.fuel_capacity * 0.2:
        status = "RETURN SOON"
    else:
        status = "SAFE TO GO"

    # fake cost model (you can improve later with fuel price API)
    fuel_price_per_litre = 105
    cost = adjusted_fuel * fuel_price_per_litre

    # recommendation logic
    if status == "NOT SAFE":
        recommendation = "Fuel insufficient. Refuel before departure."
    elif status == "RETURN SOON":
        recommendation = "Proceed with caution. Return soon."
    else:
        recommendation = "Trip is safe. Maintain steady speed."

    return {
        "fuel_level": round((data.current_fuel / data.fuel_capacity) * 100, 2),
        "consumption": data.consumption_per_km,
        "cost": round(cost, 2),
        "sea_condition": data.sea_condition,
        "recommendation": recommendation,
        "status": status
    }