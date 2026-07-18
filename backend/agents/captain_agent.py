from agents.weather_agent import get_weather
from agents.sos_agent import activate_sos


def process_query(query):

    query = query.lower()

    if "weather" in query or "fish" in query:
        return get_weather()

    elif "sos" in query or "help" in query:
        return activate_sos(10.78,79.12)

    else:
        return {
            "message":"Sorry, I didn't understand."
        }