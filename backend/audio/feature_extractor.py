import librosa
import numpy as np

def extract_features(file_path):
    """
    Extracts a 84-dimensional acoustic feature vector:
    - 40 MFCC Means
    - 40 MFCC Variances
    - Spectral Centroid Mean & Variance
    - Spectral Bandwidth Mean & Variance
    - Zero Crossing Rate Mean & Variance
    """
    try:
        audio, sr = librosa.load(file_path, duration=4, sr=22050)
        
        # Ensure minimum length
        if len(audio) < sr:
            audio = np.pad(audio, (0, sr - len(audio)))

        mfcc = librosa.feature.mfcc(y=audio, sr=sr, n_mfcc=40)
        mfcc_mean = np.mean(mfcc.T, axis=0)
        mfcc_std = np.std(mfcc.T, axis=0)

        centroid = librosa.feature.spectral_centroid(y=audio, sr=sr)[0]
        centroid_mean = float(np.mean(centroid))
        centroid_std = float(np.std(centroid))

        bandwidth = librosa.feature.spectral_bandwidth(y=audio, sr=sr)[0]
        bw_mean = float(np.mean(bandwidth))

        zcr = librosa.feature.zero_crossing_rate(audio)[0]
        zcr_mean = float(np.mean(zcr))
        zcr_std = float(np.std(zcr))

        features = np.hstack([
            mfcc_mean,
            mfcc_std,
            [centroid_mean, centroid_std, bw_mean, zcr_mean]
        ])

        return {
            "vector": features,
            "centroid": centroid_mean,
            "zcr": zcr_mean,
            "bandwidth": bw_mean
        }
    except Exception as e:
        print("Feature extraction note:", e)
        return None