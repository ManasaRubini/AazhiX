from fastapi import APIRouter
import random

router = APIRouter()

FISH_DB = [
    {"fish": "Tuna", "base_price": 220},
    {"fish": "Sardine", "base_price": 100},
    {"fish": "Mackerel", "base_price": 140},
    {"fish": "Pomfret", "base_price": 300},
    {"fish": "Anchovy", "base_price": 80},
    {"fish": "Salmon", "base_price": 450},
]

def calculate_demand(price):
    if price >= 350:
        return "high"
    elif price >= 150:
        return "medium"
    else:
        return "low"
def get_recommendation(price, demand):
    """
    Smart selling recommendation logic
    """

    if demand == "high" and price > 200:
        return "SELL TODAY"
    
    elif demand == "medium":
        return "WAIT 1 DAY"
    
    else:
        return "DO NOT SELL"

@router.get("/market-prices")
def get_market_prices():
    result = []

    for fish in FISH_DB:
        fluctuation = random.uniform(0.8, 1.2)
        price = round(fish["base_price"] * fluctuation, 2)

        demand = calculate_demand(price)
        recommendation = get_recommendation(price, demand)

        result.append({
            "fish": fish["fish"],
            "price": price,
            "demand": demand,
            "recommendation": recommendation
        })
    return result
