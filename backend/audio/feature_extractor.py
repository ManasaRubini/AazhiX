import librosa
import numpy as np

def extract_features(file_path):
    try:
        audio, sr = librosa.load(file_path, duration=5)
        mfcc = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=40)
        mfcc_mean = np.mean(mfcc.T, axis=0)

        centroid = librosa.feature.spectral_centroid(y=audio, sr=sr)
        zcr = librosa.feature.zero_crossing_rate(audio)

        return {
            "mfcc": mfcc_mean,
            "centroid": float(np.mean(centroid)),
            "zcr": float(np.mean(zcr))
        }
    except Exception as e:
        print("Librosa extraction note:", e)
        return None