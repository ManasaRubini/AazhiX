from roboflow import Roboflow
from utils.constants import ROBOFLOW_API_KEY
from vision.detect_plastic import detect_objects

def analyze_plastic(image_path):
    if ROBOFLOW_API_KEY:
        try:
            rf = Roboflow(api_key=ROBOFLOW_API_KEY)
            project = rf.workspace().project("marine-plastic")
            model = project.version(1).model
        except Exception as e:
            print("Roboflow initialization note:", e)

    detections = detect_objects(image_path)

    return {
        "plastic_detected": len(detections) > 0,
        "pollution_level":
            "HIGH" if len(detections) > 3 else
            "MEDIUM" if len(detections) > 1 else
            "LOW",
        "detections": detections
    }