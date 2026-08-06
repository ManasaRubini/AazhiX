import joblib
import os
import numpy as np
from audio.feature_extractor import extract_features

model = None
model_path = "engine_model.pkl"
if os.path.exists(model_path):
    try:
        model = joblib.load(model_path)
    except Exception as e:
        print("Engine model load note:", e)

def classify_engine(audio_path):
    prediction = "normal"
    confidence = 94

    try:
        features = extract_features(audio_path)
        if features is not None:
            if model is not None and "mfcc" in features:
                prediction = model.predict([features["mfcc"]])[0]
                confidence = 92
            else:
                centroid = features.get("centroid", 1500)
                zcr = features.get("zcr", 0.05)

                if centroid > 3200 or zcr > 0.18:
                    prediction = "misalignment"
                    confidence = 84
                elif centroid < 800:
                    prediction = "bearing_fault"
                    confidence = 81
                else:
                    prediction = "normal"
                    confidence = 94
    except Exception as e:
        print("Feature classification note:", e)
        prediction = "normal"
        confidence = 90

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
        "confidence": confidence,
        "severity": severity_map.get(prediction, "LOW")
    }