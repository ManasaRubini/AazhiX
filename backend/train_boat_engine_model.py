import os
import glob
import joblib
import numpy as np
from sklearn.ensemble import RandomForestClassifier, ExtraTreesClassifier
from sklearn.preprocessing import StandardScaler
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

from audio.feature_extractor import extract_features

def train_boat_engine_model(dataset_dir="dataset/boat_engines", output_model_path="engine_model.pkl", output_scaler_path="scaler.pkl"):
    print("Training Boat Engine Acoustic ML Classifier...")
    X = []
    y = []

    classes = ["normal", "bearing_fault", "misalignment", "pump_cavitation"]

    for label in classes:
        folder = os.path.join(dataset_dir, label)
        wav_files = glob.glob(os.path.join(folder, "*.wav"))

        print(f"Extracting features from {len(wav_files)} samples for class '{label}'...")
        for filepath in wav_files:
            res = extract_features(filepath)
            if res is not None and "vector" in res:
                X.append(res["vector"])
                y.append(label)

    if len(X) == 0:
        print("No WAV files found! Please run 'python dataset/generate_boat_dataset.py' first.")
        return

    X = np.array(X)
    y = np.array(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42, test_size=0.2, stratify=y)

    scaler = StandardScaler()
    X_train_scaled = scaler.fit_transform(X_train)
    X_test_scaled = scaler.transform(X_test)

    clf = ExtraTreesClassifier(n_estimators=150, random_state=42)
    clf.fit(X_train_scaled, y_train)

    y_pred = clf.predict(X_test_scaled)
    acc = accuracy_score(y_test, y_pred)
    print(f"\nModel Training Complete! Test Accuracy: {acc * 100:.2f}%\n")
    print(classification_report(y_test, y_pred))

    joblib.dump(clf, output_model_path)
    joblib.dump(scaler, output_scaler_path)
    print(f"Trained model saved to: '{output_model_path}' and scaler saved to: '{output_scaler_path}'")

if __name__ == "__main__":
    train_boat_engine_model()
