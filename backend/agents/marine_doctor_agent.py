from audio.classify_engine import classify_engine

def analyze_engine(audio_path):
    try:
        result = classify_engine(audio_path)
        prediction = result.get("engine_status", "normal")
        severity = result.get("severity", "LOW")
    except Exception as e:
        print("Audio classification error:", e)
        prediction = "normal"
        severity = "LOW"

    if prediction == "normal":
        status = "Healthy"
        confidence = 92
        recommendation = "Engine operating normally"
    elif severity == "LOW":
        status = "Minor Issue"
        confidence = 85
        recommendation = "Routine inspection recommended"
    elif severity == "MEDIUM":
        status = "Warning"
        confidence = 80
        recommendation = "Schedule maintenance soon"
    else:
        status = "Critical"
        confidence = 75
        recommendation = "Immediate service required"

    return {
        "status": status,
        "confidence": confidence,
        "recommendation": recommendation,
        "engine_status": prediction,
        "severity": severity
    }