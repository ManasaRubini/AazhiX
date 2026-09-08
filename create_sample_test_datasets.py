import os
import numpy as np
import scipy.io.wavfile as wav

def create_sample_test_data(output_dir="sample_test_data"):
    """
    Creates ready-to-use sample dataset test files for team testing & demonstration:
    1. Marine Doctor sample WAV audio files (normal, bearing fault, misalignment, cavitation)
    2. Sample voice query reference card for Gemini AI in 5 languages
    """
    audio_dir = os.path.join(output_dir, "marine_doctor_samples")
    os.makedirs(audio_dir, exist_ok=True)

    sr = 22050
    duration_sec = 4
    t = np.linspace(0, duration_sec, int(sr * duration_sec))

    samples = {
        "sample_boat_normal_engine.wav": {
            "desc": "Normal smooth diesel boat engine rumble",
            "func": lambda t: 0.5 * np.sin(2 * np.pi * 120 * t) + 0.3 * np.sin(2 * np.pi * 240 * t) + 0.04 * np.random.normal(0, 1, len(t))
        },
        "sample_boat_bearing_fault.wav": {
            "desc": "Bearing fault high-frequency metallic squeal",
            "func": lambda t: 0.4 * np.sin(2 * np.pi * 120 * t) + 0.5 * np.sin(2 * np.pi * 3800 * t) + 0.08 * np.random.normal(0, 1, len(t))
        },
        "sample_boat_misalignment.wav": {
            "desc": "Propeller shaft misalignment periodic knocking",
            "func": lambda t: (0.4 * np.sin(2 * np.pi * 120 * t)) * (0.5 * (1.0 + np.sin(2 * np.pi * 4.0 * t))) + 0.1 * np.random.normal(0, 1, len(t))
        },
        "sample_boat_pump_cavitation.wav": {
            "desc": "Bilge pump cavitation sputtering noise",
            "func": lambda t: 0.4 * np.sin(2 * np.pi * 120 * t) + 0.35 * np.random.choice([0.0, 1.0], size=len(t), p=[0.88, 0.12]) + 0.1 * np.random.normal(0, 1, len(t))
        }
    }

    print("Generating Marine Doctor test WAV samples...")
    for filename, item in samples.items():
        audio = item["func"](t)
        audio = audio / np.max(np.abs(audio))
        audio_int16 = (audio * 32767).astype(np.int16)
        path = os.path.join(audio_dir, filename)
        wav.write(path, sr, audio_int16)
        print(f"Created: {filename} ({item['desc']})")

    # Create Sample Queries Reference file
    query_card_path = os.path.join(output_dir, "sample_test_queries.txt")
    with open(query_card_path, "w", encoding="utf-8") as f:
        f.write("""AazhiX — Sample Test Queries & Commands for Voice & AI Testing
===================================================================

1. Tamil (தமிழ்) Sample Voice Queries:
   - "வானிலை மற்றும் அலை உயரம் எப்படி உள்ளது?" (Weather & Wave Height)
   - "எரிபொருள் நிலை பாதுகாப்பாக உள்ளதா?" (Fuel Safety Status)
   - "அருகிலுள்ள மீன்பிடி மண்டலம் எங்குள்ளது?" (Nearest Fish Zone)
   - "சூரை மீன் சந்தை விலை என்ன?" (Tuna Market Rate)

2. Hindi (हिंदी) Sample Voice Queries:
   - "मौसम और लहरों की स्थिति क्या है?"
   - "क्या मेरा ईंधन स्तर सुरक्षित है?"
   - "सबसे पास मछली पकड़ने का क्षेत्र कहां है?"

3. English Sample Voice Queries:
   - "What is the current wave height and weather forecast?"
   - "Is my fuel capacity safe to complete the voyage?"
   - "Where is the nearest potential fishing zone with high probability?"
   - "What is the market price of Tuna fish today?"

4. Plastic Vision Test:
   - Take a picture of any clear plastic water bottle or plastic wrapper.
   - Tap "Scan Ocean Image" in Plastic Alert screen and select the image.
   - Result: "Plastic Bottle / Container (88.0%)" translated into Tamil ("மிதக்கும் பிளாஸ்டிக் கழிவு").
""")

    print(f"\nSample test dataset created successfully inside: '{output_dir}/'")

if __name__ == "__main__":
    create_sample_test_data()
