import os
import numpy as np
import scipy.io.wavfile as wav

def generate_augmented_boat_dataset(output_dir="dataset/boat_engines", samples_per_class=50, duration_sec=4, sr=22050):
    """
    Generates 200 augmented boat engine acoustic samples across 4 classes:
    1. normal (Smooth boat diesel engine rumble, 100-800Hz)
    2. bearing_fault (High-frequency metallic grinding/squeal, 3000-6000Hz)
    3. misalignment (Propeller shaft periodic knocking, 3-6Hz pulse modulation)
    4. pump_cavitation (Bilge pump cavitation sputtering noise, high ZCR)
    """
    classes = ["normal", "bearing_fault", "misalignment", "pump_cavitation"]
    t = np.linspace(0, duration_sec, int(sr * duration_sec))

    for cls_name in classes:
        cls_dir = os.path.join(output_dir, cls_name)
        os.makedirs(cls_dir, exist_ok=True)

        for i in range(samples_per_class):
            # Base engine fundamental frequency with slight variation
            base_freq = 110 + np.random.uniform(-15, 15)
            
            # Harmonic series
            audio = (
                0.6 * np.sin(2 * np.pi * base_freq * t) +
                0.35 * np.sin(2 * np.pi * 2 * base_freq * t) +
                0.2 * np.sin(2 * np.pi * 3 * base_freq * t)
            )

            # Class specific acoustic signatures
            if cls_name == "normal":
                # Clean engine rumble with mild background sea noise
                noise_level = np.random.uniform(0.02, 0.06)
                audio += noise_level * np.random.normal(0, 1, len(t))

            elif cls_name == "bearing_fault":
                # High frequency metallic squeal (3200-5500Hz)
                squeal_freq = np.random.uniform(3200, 5500)
                squeal_amp = np.random.uniform(0.4, 0.7)
                squeal = squeal_amp * np.sin(2 * np.pi * squeal_freq * t)
                audio += squeal + np.random.uniform(0.05, 0.1) * np.random.normal(0, 1, len(t))

            elif cls_name == "misalignment":
                # Shaft knocking modulation (3-6 Hz periodic pulse)
                knock_rate = np.random.uniform(3.5, 5.5)
                pulse = 0.5 * (1.0 + np.sin(2 * np.pi * knock_rate * t))
                audio = audio * pulse + np.random.uniform(0.06, 0.12) * np.random.normal(0, 1, len(t))

            elif cls_name == "pump_cavitation":
                # Irregular sputtering noise bursts
                burst_prob = np.random.uniform(0.12, 0.22)
                bursts = np.random.choice([0.0, 1.0], size=len(t), p=[1.0 - burst_prob, burst_prob])
                high_noise = 0.4 * np.random.normal(0, 1, len(t)) * bursts
                audio += high_noise + 0.05 * np.random.normal(0, 1, len(t))

            # Normalize audio
            max_val = np.max(np.abs(audio))
            if max_val > 0:
                audio = audio / max_val

            audio_int16 = (audio * 32767).astype(np.int16)
            file_path = os.path.join(cls_dir, f"boat_{cls_name}_{i+1}.wav")
            wav.write(file_path, sr, audio_int16)

    print(f"Generated augmented boat engine acoustic dataset at: {output_dir}")
    print(f"Total samples: {len(classes) * samples_per_class} WAV files across {len(classes)} classes.")

if __name__ == "__main__":
    generate_augmented_boat_dataset()
