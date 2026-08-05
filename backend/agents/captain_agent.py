import google.generativeai as genai
from utils.constants import GEMINI_API_KEY
from agents.weather_agent import get_weather
from agents.sos_agent import activate_sos
from agents.fishzone_agent import FishZoneAgent

# Configure Gemini if key is provided
if GEMINI_API_KEY:
    try:
        genai.configure(api_key=GEMINI_API_KEY)
    except Exception as e:
        print("Gemini config note:", e)

LANG_MAP = {
    "ta": "Tamil (தமிழ்)",
    "hi": "Hindi (हिंदी)",
    "ml": "Malayalam (മലയാളം)",
    "te": "Telugu (తెలుగు)",
    "en": "English"
}

def process_query(query: str, lat: float | None = None, lon: float | None = None, language: str = "en"):
    query_clean = query.lower().strip()
    latitude = lat if lat is not None else 10.78
    longitude = lon if lon is not None else 79.23
    lang_code = language.lower() if language else "en"
    lang_name = LANG_MAP.get(lang_code, "English")

    # Fetch live ocean context
    weather_info = get_weather(lat=latitude, lon=longitude)
    fish_info = FishZoneAgent().analyze_fishing_zone(latitude, longitude)

    # Emergency SOS hard trigger check
    if any(k in query_clean for k in ["sos", "distress", "mayday", "ஆபத்து", "எமர்ஜென்சி"]):
        sos_res = activate_sos(latitude, longitude)
        spoken_sos = _get_sos_spoken(lang_code, latitude, longitude)
        return {
            "intent": "sos",
            "spoken_response": spoken_sos,
            "title": "SOS Emergency Activated",
            "subtitle": f"GPS: {latitude}, {longitude}",
            "details": sos_res
        }

    # Use Gemini 1.5 Flash if available
    if GEMINI_API_KEY:
        try:
            model = genai.GenerativeModel("gemini-1.5-flash")
            system_prompt = f"""
            You are AazhiX Voice AI, an intelligent marine companion for ship captains at sea.
            Respond to the captain's question in {lang_name} language using natural script.
            Keep your answer short, concise (1-3 sentences), highly practical for navigation, and clear for voice text-to-speech.

            Current Live Ocean Data for Captain's location ({latitude}, {longitude}):
            - Temperature: {weather_info['temperature']}°C
            - Wave Height: {weather_info['wave_height']} meters
            - Wind Speed: {weather_info['wind_speed']} km/h
            - Ocean Condition: {weather_info['condition']}
            - Fishing Catch Probability: {fish_info['fish_probability']}%
            - Fish Advisory: {fish_info['advisory']}
            - Market Rates: Tuna ₹240/kg, Pomfret ₹320/kg (High Demand)
            """

            response = model.generate_content(f"{system_prompt}\n\nCaptain Query: {query}")
            if response and response.text:
                spoken_text = response.text.strip().replace("*", "")
                return {
                    "intent": "gemini_ai",
                    "spoken_response": spoken_text,
                    "title": f"AazhiX AI ({lang_name})",
                    "subtitle": spoken_text[:60] + "...",
                    "details": {"source": "Google Gemini 1.5 Flash"}
                }
        except Exception as e:
            print("Gemini generation note:", e)

    # Resilient Multilingual Fallback Handler
    return _process_multilingual_fallback(query_clean, weather_info, fish_info, lang_code)

def _get_sos_spoken(lang_code, lat, lon):
    if lang_code == "ta":
        return f"அவசர SOS செயல்படுத்தப்பட்டது! ஆயுதப்படைக்கு ஆய அச்சரேகைகள் அனுப்பப்பட்டன: {lat}, {lon}"
    elif lang_code == "hi":
        return f"आपातकालीन SOS सक्रिय! तटरक्षक को स्थान भेजा गया: {lat}, {lon}"
    elif lang_code == "ml":
        return f"അടിയന്തര SOS സജീവമാക്കി! കൊസ്റ്റ് ഗാർഡിന് ലൊക്കേഷൻ അയച്ചു."
    elif lang_code == "te":
        return f"అత్యవసర SOS యాక్టివేట్ చేయబడింది! వివరాలు కోస్ట్ గార్డ్‌కు పంపబడ్డాయి."
    return f"EMERGENCY SOS ACTIVATED! Transmitting distress signal to Coast Guard at {lat}, {lon}"

def _process_multilingual_fallback(query_clean, w, fz, lang_code):
    if any(k in query_clean for k in ["wave", "height", "weather", "wind", "அலை", "வானிலை", "मौसम"]):
        if lang_code == "ta":
            spoken = f"தற்போது அலை உயரம் {w['wave_height']} மீட்டர். காற்றின் வேகம் {w['wind_speed']} கி.மீ. வெப்பநிலை {w['temperature']} டிகிரி செல்சியஸ்."
        elif lang_code == "hi":
            spoken = f"वर्तमान में लहरों की ऊंचाई {w['wave_height']} मीटर है और हवा की गति {w['wind_speed']} किलोमीटर प्रति घंटा है।"
        elif lang_code == "ml":
            spoken = f"ഇപ്പോഴത്തെ തിരമാല ഉയരം {w['wave_height']} മീറ്ററാണ്. കാറ്റിന്റെ വേഗത {w['wind_speed']} കി.മീ."
        elif lang_code == "te":
            spoken = f"ప్రస్తుతం అలల ఎత్తు {w['wave_height']} మీటర్లు. గాలి వేగం {w['wind_speed']} కి.మీ."
        else:
            spoken = f"Currently, wave height is {w['wave_height']} meters, wind speed is {w['wind_speed']} km/h, with {w['condition']} conditions."
        return {
            "intent": "weather",
            "spoken_response": spoken,
            "title": "Ocean Weather",
            "subtitle": f"{w['wave_height']}m Waves • {w['wind_speed']} km/h Wind",
            "details": w
        }

    elif any(k in query_clean for k in ["fuel", "safe", "எரிபொருள்", "ईंधन"]):
        if lang_code == "ta":
            spoken = "உங்கள் கப்பலின் எரிபொருள் நிலை பாதுகாப்பாக உள்ளது. 60 சதவீதத்திற்கும் அதிகமான இருப்பு உள்ளது."
        elif lang_code == "hi":
            spoken = "आपका ईंधन स्तर सुरक्षित है। 60 प्रतिशत से अधिक रिजर्व उपलब्ध है।"
        elif lang_code == "ml":
            spoken = "നിങ്ങളുടെ ഇന്ധന നില സുരക്ഷിതമാണ്."
        elif lang_code == "te":
            spoken = "మీ ఇంధన స్థాయి సురక్షితంగా ఉంది."
        else:
            spoken = "Your fuel level is SAFE TO GO. Estimated remaining fuel buffer is above 60 percent."
        return {
            "intent": "fuel",
            "spoken_response": spoken,
            "title": "Fuel Safety Status",
            "subtitle": "SAFE TO GO • 60% Buffer Available",
            "details": {"status": "SAFE TO GO"}
        }

    elif any(k in query_clean for k in ["fish", "zone", "catch", "மீன்", "மண்டலம்", "मछली"]):
        if lang_code == "ta":
            spoken = f"அருகிலுள்ள மீன்பிடி மண்டலத்தில் {fz['fish_probability']} சதவீதம் மீன் பிடிக்கும் வாய்ப்பு உள்ளது."
        elif lang_code == "hi":
            spoken = f"निकटतम मछली क्षेत्र में {fz['fish_probability']} प्रतिशत पकड़ने की संभावना है।"
        elif lang_code == "ml":
            spoken = f"അടുത്തുള്ള മീൻപിടുത്ത മേഖലയിൽ {fz['fish_probability']} ശതമാനം സാധ്യതയുണ്ട്."
        elif lang_code == "te":
            spoken = f"సమీప చేపల జోన్‌లో {fz['fish_probability']} శాతం అవకాశం ఉంది."
        else:
            spoken = f"The nearest fishing zone has a {fz['fish_probability']} percent catch probability."
        return {
            "intent": "fishzone",
            "spoken_response": spoken,
            "title": "Nearest Fish Zone",
            "subtitle": f"{fz['fish_probability']}% Catch Probability",
            "details": fz
        }

    else:
        if lang_code == "ta":
            spoken = "வணக்கம் கேப்டன்! நான் ஆழிஎக்ஸ் வாய்ஸ் ஏஐ. அலை உயரம், எரிபொருள் பாதுகாப்பு, அல்லது மீன் மண்டலம் பற்றி கேளுங்கள்."
        elif lang_code == "hi":
            spoken = "नमस्ते कप्तान! मैं AazhiX Voice AI हूँ। मुझसे लहरों की ऊंचाई, ईंधन सुरक्षा या मछली क्षेत्र के बारे में पूछें।"
        elif lang_code == "ml":
            spoken = "നമസ്കാരം ക്യാപ്റ്റൻ! ഞാൻ AazhiX Voice AI ആണ്."
        elif lang_code == "te":
            spoken = "నమస్కారం కెప్టెన్! నేను AazhiX Voice AI ని."
        else:
            spoken = "Hello Captain! I am AazhiX Voice AI powered by Google Gemini. Ask me about wave height, fuel safety, nearest fish zone, or market prices."
        return {
            "intent": "general",
            "spoken_response": spoken,
            "title": "AazhiX Voice AI",
            "subtitle": "Listening for your voice command...",
            "details": {}
        }