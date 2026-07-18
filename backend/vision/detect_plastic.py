from ultralytics import YOLO

model = YOLO("yolov8n.pt")

def detect_objects(image_path):

    results = model(image_path)

    detections = []

    for result in results:
        for box in result.boxes:

            cls = int(box.cls[0])
            conf = float(box.conf[0])

            obj = model.names[cls]

            print("Detected:", obj, conf)

            detections.append({
                "object": obj,
                "confidence": round(conf, 2)
            })

    return detections