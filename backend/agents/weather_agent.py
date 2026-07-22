import requests

def get_weather(location="Chennai", lat=None, lon=None):
    # 1. Try Open-Meteo live API (Real-time marine weather, no API key needed)
    try:
        latitude = lat if lat is not None else 13.0827
        longitude = lon if lon is not None else 80.2707

        url = f"https://api.open-meteo.com/v1/forecast?latitude={latitude}&longitude={longitude}&current=temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code"
        res = requests.get(url, timeout=4)
        if res.status_code == 200:
            data = res.json()
            current = data.get("current", {})
            temp = float(current.get("temperature_2m", 28.5))
            humidity = float(current.get("relative_humidity_2m", 75.0))
            wind = float(current.get("wind_speed_10m", 15.0))
            code = current.get("weather_code", 0)

            code_map = {
                0: "Clear Sky", 1: "Mainly Clear", 2: "Partly Cloudy", 3: "Overcast",
                45: "Foggy", 51: "Drizzle", 61: "Rain", 80: "Showers", 95: "Thunderstorm"
            }
            condition = code_map.get(code, "Partly Cloudy")
            wave_height = round(max(0.4, 0.025 * (wind ** 1.3)), 1)

            return {
                "temperature": round(temp, 1),
                "humidity": round(humidity, 1),
                "wind_speed": round(wind, 1),
                "wave_height": wave_height,
                "condition": condition
            }
    except Exception as e:
        print("Live Open-Meteo note:", e)

    # 2. Try wttr.in live endpoint
    try:
        url = f"https://wttr.in/{location}?format=j1"
        res = requests.get(url, timeout=4)
        if res.status_code == 200:
            data = res.json()
            curr = data["current_condition"][0]
            wind_kmh = float(curr["windspeedKmph"])
            return {
                "temperature": float(curr["temp_C"]),
                "humidity": float(curr["humidity"]),
                "wind_speed": wind_kmh,
                "wave_height": round(max(0.5, 0.025 * (wind_kmh ** 1.3)), 1),
                "condition": curr["weatherDesc"][0]["value"]
            }
    except Exception as e:
        print("Live wttr.in note:", e)

    # Fallback default
    return {
        "temperature": 29.0,
        "humidity": 78.0,
        "wind_speed": 18.0,
        "wave_height": 1.4,
        "condition": "Partly Cloudy"
    }