import os
import numpy as np
from sklearn.ensemble import RandomForestClassifier
import joblib
from audio.feature_extractor import extract_features

dataset_path = r"dataset\archive"

X = []
y = []

print("Starting dataset loading...")

for dev_folder in os.listdir(dataset_path):

    dev_path = os.path.join(dataset_path, dev_folder)

    if not os.path.isdir(dev_path):
        continue

    # inside dev_data_xxx → fan/gearbox/pump/valve
    for machine_class in os.listdir(dev_path):

        class_path = os.path.join(dev_path, machine_class, "train")

        if not os.path.exists(class_path):
            continue

        for file in os.listdir(class_path):

            if not file.lower().endswith(".wav"):
                continue

            file_path = os.path.join(class_path, file)

            try:
                print("Processing:", file_path)

                features = extract_features(file_path)

                if features is None:
                    continue

                features = np.array(features).flatten()

                X.append(features)

                filename = file.lower()

                if "normal" in filename:
                    y.append("normal")
                elif "anomaly" in filename or "abnormal" in filename:
                    y.append("abnormal")
                else:
                    continue
            except Exception as e:
                print("Error:", file_path, e)

print("\nDataset loaded")
print("X size:", len(X))
print("y size:", len(y))

if len(X) == 0:
    raise ValueError("No data found. Check dataset paths.")

X = np.array(X)
y = np.array(y)

model = RandomForestClassifier(n_estimators=100, random_state=42)
model.fit(X, y)

joblib.dump(model, "engine_model.pkl")

print("Model trained successfully 🚀")
