import requests


def get_weather(city):

    url = f"https://wttr.in/{city}?format=j1"

    response = requests.get(url)

    data = response.json()

    current = data["current_condition"][0]

    return {
        "temperature": float(current["temp_C"]),
        "humidity": float(current["humidity"]),
        "wind_speed": float(current["windspeedKmph"]),
        "wave_height": 1.5,
        "condition": current["weatherDesc"][0]["value"]
    }