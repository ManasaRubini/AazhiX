import os
import glob
import joblib
import numpy as np
import librosa
from sklearn.ensemble import RandomForestClassifier
from sklearn.model_selection import train_test_split
from sklearn.metrics import classification_report, accuracy_score

def extract_audio_features(file_path):
    """
    Extracts 40 MFCCs from a boat engine audio file.
    """
    try:
        audio, sr = librosa.load(file_path, duration=5)
        mfcc = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=40)
        return np.mean(mfcc.T, axis=0)
    except Exception as e:
        print(f"Error reading {file_path}: {e}")
        return None

def train_boat_engine_model(dataset_dir="dataset/boat_engines", output_model_path="engine_model.pkl"):
    """
    Trains a Random Forest Acoustic Classifier specifically for boat engine sound diagnostics.
    """
    print("Training Boat Engine Acoustic Classifier...")
    X = []
    y = []

    classes = ["normal", "bearing_fault", "misalignment", "pump_cavitation"]

    for label in classes:
        folder = os.path.join(dataset_dir, label)
        wav_files = glob.glob(os.path.join(folder, "*.wav"))

        print(f"Loading {len(wav_files)} samples for class: '{label}'...")
        for filepath in wav_files:
            feats = extract_audio_features(filepath)
            if feats is not None:
                X.append(feats)
                y.append(label)

    if len(X) == 0:
        print("❌ No WAV files found! Please run 'python dataset/generate_boat_dataset.py' first.")
        return

    X = np.array(X)
    y = np.array(y)

    X_train, X_test, y_train, y_test = train_test_split(X, y, random_state=42, test_size=0.2, stratify=y)

    # Train Random Forest Classifier
    clf = RandomForestClassifier(n_estimators=100, random_state=42)
    clf.fit(X_train, y_train)

    # Evaluate
    y_pred = clf.predict(X_test)
    acc = accuracy_score(y_test, y_pred)
    print(f"\nModel Training Complete! Accuracy: {acc * 100:.2f}%\n")
    print(classification_report(y_test, y_pred))

    # Export trained model
    joblib.dump(clf, output_model_path)
    print(f"Trained model saved successfully to: '{output_model_path}'")

if __name__ == "__main__":
    train_boat_engine_model()
