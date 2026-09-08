import os
import numpy as np
import scipy.io.wavfile as wav

def generate_boat_audio_dataset(output_dir="dataset/boat_engines", samples_per_class=10, duration_sec=3, sr=22050):
    """
    Generates a realistic acoustic dataset of boat diesel engines across 4 operational states:
    1. normal: Smooth boat diesel motor rumble (low frequency 100-800Hz)
    2. bearing_fault: High-frequency metallic grinding/squeal (3000-6000Hz)
    3. misalignment: Periodic shaft knocking & vibration (low frequency pulsing)
    4. pump_cavitation: Irregular air-sputter noise
    """
    classes = ["normal", "bearing_fault", "misalignment", "pump_cavitation"]
    t = np.linspace(0, duration_sec, int(sr * duration_sec))

    for cls_name in classes:
        cls_dir = os.path.join(output_dir, cls_name)
        os.makedirs(cls_dir, exist_ok=True)

        for i in range(samples_per_class):
            # Base engine diesel fundamental rumble (120 Hz + harmonics)
            base_freq = 120 + np.random.uniform(-10, 10)
            audio = 0.5 * np.sin(2 * np.pi * base_freq * t) + 0.3 * np.sin(2 * np.pi * 2 * base_freq * t)

            if cls_name == "normal":
                # Smooth ocean diesel engine sound with light water noise
                noise = 0.05 * np.random.normal(0, 1, len(t))
                audio = audio + noise

            elif cls_name == "bearing_fault":
                # Add high-frequency metallic squeal (3500 Hz)
                metallic_freq = 3500 + np.random.uniform(-200, 200)
                squeal = 0.4 * np.sin(2 * np.pi * metallic_freq * t)
                audio = audio + squeal + 0.08 * np.random.normal(0, 1, len(t))

            elif cls_name == "misalignment":
                # Add periodic mechanical knock (4 Hz pulse modulation)
                knock_mod = 0.5 * (1.0 + np.sin(2 * np.pi * 4.0 * t))
                audio = audio * knock_mod + 0.1 * np.random.normal(0, 1, len(t))

            elif cls_name == "pump_cavitation":
                # Add sputtering cavitation bursts
                bursts = 0.3 * np.random.choice([0.0, 1.0], size=len(t), p=[0.9, 0.1])
                audio = audio + bursts + 0.12 * np.random.normal(0, 1, len(t))

            # Normalize audio
            audio = audio / np.max(np.abs(audio))
            audio_int16 = (audio * 32767).astype(np.int16)

            file_path = os.path.join(cls_dir, f"boat_{cls_name}_{i+1}.wav")
            wav.write(file_path, sr, audio_int16)

    print(f"Generated boat engine acoustic dataset at: {output_dir}")
    print(f"Total samples: {len(classes) * samples_per_class} WAV files across {len(classes)} classes.")

if __name__ == "__main__":
    generate_boat_audio_dataset()
