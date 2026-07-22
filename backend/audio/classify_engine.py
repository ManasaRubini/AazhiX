import joblib
import os
from audio.feature_extractor import extract_features

model = None
model_path = "engine_model.pkl"
if os.path.exists(model_path):
    try:
        model = joblib.load(model_path)
    except Exception as e:
        print("Engine model load note:", e)

def classify_engine(audio_path):
    try:
        features = extract_features(audio_path)
        if model is not None and features is not None:
            prediction = model.predict([features])[0]
        else:
            prediction = "normal"
    except Exception as e:
        print("Feature extraction note:", e)
        prediction = "normal"

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
        "severity": severity_map.get(prediction, "LOW")
    }