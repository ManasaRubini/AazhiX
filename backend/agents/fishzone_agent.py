# agents/fishzone_agent.py

import random


class FishZoneAgent:

    def __init__(self):
        pass

    def analyze_fishing_zone(self, lat, lon, species="Any"):

        fish_probability = random.randint(60, 95)

        if fish_probability >= 80:
            advisory = "Excellent fishing opportunity."
        elif fish_probability >= 70:
            advisory = "Moderate fishing opportunity."
        else:
            advisory = "Low fish activity expected."

        return {
            "latitude": lat,
            "longitude": lon,
            "species": species,
            "fish_probability": fish_probability,
            "advisory": advisory
        }