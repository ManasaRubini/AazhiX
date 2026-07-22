from fastapi import APIRouter
from datetime import datetime, timezone

router = APIRouter()

FISH_DB = [
    {"fish": "Tuna", "base_price": 240},
    {"fish": "Sardine", "base_price": 110},
    {"fish": "Mackerel", "base_price": 150},
    {"fish": "Pomfret", "base_price": 320},
    {"fish": "Anchovy", "base_price": 90},
    {"fish": "Salmon", "base_price": 480},
]

def calculate_demand(price, base_price):
    ratio = price / base_price
    if ratio >= 1.08:
        return "high"
    elif ratio >= 0.95:
        return "medium"
    else:
        return "low"

def get_recommendation(price, demand):
    if demand == "high":
        return "SELL TODAY"
    elif demand == "medium":
        return "WAIT 1 DAY"
    else:
        return "DO NOT SELL"

@router.get("/market-prices")
def get_market_prices():
    result = []
    now = datetime.now(timezone.utc)
    hour = now.hour
    day = now.weekday()

    # Real-time daily market cycle modifier (morning fresh-catch peak & weekend factor)
    time_factor = 1.0 + (0.08 if 4 <= hour <= 12 else -0.04) + (0.05 if day >= 5 else 0.0)

    for idx, fish in enumerate(FISH_DB):
        fish_modifier = ((hour * 7 + idx * 13) % 17 - 8) / 100.0
        price = round(fish["base_price"] * (time_factor + fish_modifier), 2)

        demand = calculate_demand(price, fish["base_price"])
        recommendation = get_recommendation(price, demand)

        result.append({
            "fish": fish["fish"],
            "price": price,
            "demand": demand,
            "recommendation": recommendation
        })
    return result
