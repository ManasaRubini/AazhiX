import joblib
from audio.feature_extractor import extract_features

model = joblib.load("engine_model.pkl")

def classify_engine(audio_path):

    features = extract_features(audio_path)

    prediction = model.predict([features])[0]

    severity_map = {
        "normal": "LOW",
        "bearing_fault": "HIGH",
        "misalignment": "MEDIUM",
        "unbalance": "MEDIUM",
        "pump": "LOW",
    }

    return {
        "engine_status": prediction,
        "issue": prediction,
        "severity": severity_map.get(prediction, "UNKNOWN")
    }