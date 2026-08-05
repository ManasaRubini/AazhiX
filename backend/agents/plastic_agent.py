from roboflow import Roboflow
from utils.constants import ROBOFLOW_API_KEY
from vision.detect_plastic import detect_objects

def analyze_plastic(image_path):
    detections = []

    if ROBOFLOW_API_KEY:
        try:
            rf = Roboflow(api_key=ROBOFLOW_API_KEY)
            project = rf.workspace().project("marine-plastic")
            model = project.version(1).model
            prediction = model.predict(image_path, confidence=40, overlap=30).json()

            for pred in prediction.get("predictions", []):
                detections.append({
                    "object": f"Plastic {pred.get('class', 'Debris').title()}",
                    "confidence": round(float(pred.get("confidence", 0.85)), 2)
                })
        except Exception as e:
            print("Roboflow inference note:", e)

    # If Roboflow did not return detections or API key is not present, use YOLOv8 + OpenCV engine
    if len(detections) == 0:
        detections = detect_objects(image_path)

    has_plastic = len(detections) > 0
    level = "HIGH" if len(detections) >= 3 else ("MEDIUM" if len(detections) >= 1 else "LOW")

    return {
        "plastic_detected": has_plastic,
        "pollution_level": level,
        "detections": detections
    }