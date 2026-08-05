from agents.weather_agent import get_weather
from agents.sos_agent import activate_sos
from agents.fishzone_agent import FishZoneAgent

def process_query(query: str, lat: float | None = None, lon: float | None = None):
    query_clean = query.lower().strip()
    latitude = lat if lat is not None else 10.78
    longitude = lon if lon is not None else 79.23

    # 1. Wave Height & Weather Intent
    if any(k in query_clean for k in ["wave", "height", "weather", "wind", "temp", "forecast", "sea state"]):
        w = get_weather(lat=latitude, lon=longitude)
        spoken = f"Currently, wave height is {w['wave_height']} meters, wind speed is {w['wind_speed']} kilometers per hour, temperature is {w['temperature']} degrees, with {w['condition']} conditions."
        return {
            "intent": "weather",
            "spoken_response": spoken,
            "title": "Ocean Weather",
            "subtitle": f"{w['wave_height']}m Waves • {w['wind_speed']} km/h Wind",
            "details": w
        }

    # 2. Fuel Safety Intent
    elif any(k in query_clean for k in ["fuel", "diesel", "safe on fuel", "consumption", "range"]):
        spoken = "Your fuel level is SAFE TO GO. Estimated remaining fuel buffer is above 60 percent for your return journey."
        return {
            "intent": "fuel",
            "spoken_response": spoken,
            "title": "Fuel Safety Status",
            "subtitle": "SAFE TO GO • 60% Buffer Available",
            "details": {
                "status": "SAFE TO GO",
                "recommendation": "Trip is safe. Maintain steady cruising speed."
            }
        }

    # 3. Nearest Fish Zone Intent
    elif any(k in query_clean for k in ["fish zone", "nearest fish", "where to fish", "catch", "fishing", "zone"]):
        fz = FishZoneAgent().analyze_fishing_zone(latitude, longitude)
        spoken = f"The nearest fishing zone has a {fz['fish_probability']} percent catch probability. {fz['advisory']}"
        return {
            "intent": "fishzone",
            "spoken_response": spoken,
            "title": "Nearest Fish Zone",
            "subtitle": f"{fz['fish_probability']}% Catch Probability",
            "details": fz
        }

    # 4. Market Prices Intent
    elif any(k in query_clean for k in ["market", "price", "tuna", "sardine", "pomfret", "sell", "rates"]):
        spoken = "Current market prices: Tuna is 240 rupees per kilo with high demand. Pomfret is 320 rupees per kilo. Recommendation: SELL TODAY."
        return {
            "intent": "market",
            "spoken_response": spoken,
            "title": "Fish Market Rates",
            "subtitle": "Tuna ₹240/kg • Pomfret ₹320/kg (SELL TODAY)",
            "details": {
                "Tuna": "₹240/kg (High Demand)",
                "Pomfret": "₹320/kg (High Demand)",
                "Recommendation": "SELL TODAY"
            }
        }

    # 5. Emergency SOS Intent
    elif any(k in query_clean for k in ["sos", "help", "emergency", "distress", "mayday"]):
        sos = activate_sos(latitude, longitude)
        spoken = "EMERGENCY SOS ACTIVATED! Transmitting distress signal with coordinates to Nagapattinam Coast Guard."
        return {
            "intent": "sos",
            "spoken_response": spoken,
            "title": "SOS Emergency Activated",
            "subtitle": f"Transmitting GPS: {latitude}, {longitude}",
            "details": sos
        }

    # 6. Marine Doctor Intent
    elif any(k in query_clean for k in ["engine", "doctor", "health", "noise", "repair"]):
        spoken = "Marine Doctor is ready. Hold your phone near the engine and tap Record Engine Sound for AI audio diagnosis."
        return {
            "intent": "marine_doctor",
            "spoken_response": spoken,
            "title": "Marine Doctor Diagnostic",
            "subtitle": "Ready for Engine Audio Analysis",
            "details": {"action": "Open Marine Doctor tab to record audio"}
        }

    # 7. Greeting & Default Guidance
    else:
        spoken = "Hello Captain! I am AazhiX Voice. Ask me about wave height, fuel safety, nearest fish zone, market prices, or emergency SOS."
        return {
            "intent": "general",
            "spoken_response": spoken,
            "title": "AazhiX Captain Assistant",
            "subtitle": "Listening for your voice command...",
            "details": {}
        }