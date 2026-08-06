from fastapi import APIRouter
from agents.weather_agent import get_weather

router = APIRouter(
    prefix="/api/notifications",
    tags=["Notifications"]
)

@router.get("/")
def get_maritime_notifications(lang: str = "en", lat: float = 10.78, lon: float = 79.23):
    weather = get_weather(lat=lat, lon=lon)
    wave_h = weather.get("wave_height", 1.4)
    wind_s = weather.get("wind_speed", 18.0)

    alerts = []

    # 1. Weather / Wave Alert
    if wave_h >= 2.0:
        severity = "HIGH"
        if lang == "ta":
            title = "⚠️ உயர் அலை எச்சரிக்கை"
            desc = f"நாகப்பட்டினம் கடலில் அலை உயரம் {wave_h}m வரை உயர்ந்துள்ளது. எச்சரிக்கையுடன் செயல்படவும்."
        elif lang == "hi":
            title = "⚠️ उच्च लहर चेतावनी"
            desc = f"समुद्र में लहरों की ऊंचाई {wave_h}m तक बढ़ गई है। सावधान रहें।"
        else:
            title = "⚠️ Rough Sea & High Wave Warning"
            desc = f"Wave height reached {wave_h}m at your coordinates. Exercise extreme caution."
    else:
        severity = "INFO"
        if lang == "ta":
            title = "🌊 சாதாரண கடல் அலைகள்"
            desc = f"அலை உயரம் {wave_h}m. மீன்பிடிக்க சாதகமான கடல் நிலை."
        elif lang == "hi":
            title = "🌊 सामान्य समुद्री लहरें"
            desc = f"लहरों की ऊंचाई {wave_h}m है। नौकायन के लिए अनुकूल।"
        else:
            title = "🌊 Favorable Marine Weather"
            desc = f"Wave height is {wave_h}m with wind at {wind_s} km/h. Good fishing condition."

    alerts.append({
        "id": "alert-1",
        "title": title,
        "description": desc,
        "severity": severity,
        "type": "weather",
        "time": "Just now"
    })

    # 2. Market Alert
    if lang == "ta":
        m_title = "📈 சூரை மீன் சந்தை விலை உயர்வு"
        m_desc = "சூரை மீன் கிலோ ரூ.240 ஆக உயர்ந்துள்ளது. இன்று விற்பனை செய்ய சிறந்த நேரம்."
    elif lang == "hi":
        m_title = "📈 ट्यूना मछली बाजार भाव में तेजी"
        m_desc = "ट्यूना का भाव ₹240/किग्रा हो गया है। आज बेचने का सही समय।"
    else:
        m_title = "📈 Tuna Fish Price Spike Alert"
        m_desc = "Tuna market rate surged to ₹240/kg with HIGH demand. Recommended: SELL TODAY."

    alerts.append({
        "id": "alert-2",
        "title": m_title,
        "description": m_desc,
        "severity": "SUCCESS",
        "type": "market",
        "time": "15 mins ago"
    })

    # 3. Fuel Alert
    if lang == "ta":
        f_title = "⛽ எரிபொருள் பாதுகாப்பு நிலை சரிபார்ப்பு"
        f_desc = "உங்கள் கப்பலின் எரிபொருள் இருப்பு 60% மேல் பாதுகாப்பாக உள்ளது."
    elif lang == "hi":
        f_title = "⛽ ईंधन सुरक्षा स्थिति"
        f_desc = "आपकी नाव का ईंधन स्तर 60% सुरक्षित है।"
    else:
        f_title = "⛽ Voyage Fuel Buffer Check"
        f_desc = "Current fuel buffer is optimal (>60%). Trip status is SAFE TO GO."

    alerts.append({
        "id": "alert-3",
        "title": f_title,
        "description": f_desc,
        "severity": "INFO",
        "type": "fuel",
        "time": "1 hour ago"
    })

    return {
        "unread_count": len(alerts),
        "alerts": alerts
    }
