import os
from dotenv import load_dotenv

# Load environment variables from .env file if present
load_dotenv()

OPENWEATHER_API_KEY = os.getenv("OPENWEATHER_API_KEY", "")
ROBOFLOW_API_KEY = os.getenv("ROBOFLOW_API_KEY", "")
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")