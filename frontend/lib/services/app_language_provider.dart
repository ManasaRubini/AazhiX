import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppLanguageProvider extends ChangeNotifier {
  static final AppLanguageProvider _instance = AppLanguageProvider._internal();
  factory AppLanguageProvider() => _instance;
  AppLanguageProvider._internal() {
    _loadSavedLanguage();
  }

  String _currentLanguage = "en";
  String get currentLanguage => _currentLanguage;

  static const Map<String, String> languageNames = {
    "en": "🇬🇧 English",
    "ta": "🇮🇳 தமிழ் (Tamil)",
    "hi": "🇮🇳 हिंदी (Hindi)",
    "ml": "🇮🇳 മലയാളം (Malayalam)",
    "te": "🇮🇳 తెలుగు (Telugu)",
  };

  Future<void> _loadSavedLanguage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString("app_language") ?? "en";
    notifyListeners();
  }

  Future<void> setLanguage(String langCode) async {
    if (!languageNames.containsKey(langCode)) return;
    _currentLanguage = langCode;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString("app_language", langCode);
    notifyListeners();
  }

  String getText(String key) {
    return _translations[_currentLanguage]?[key] ??
        _translations["en"]?[key] ??
        key;
  }

  // Fish Name Translator Helper
  String translateFish(String originalName) {
    if (_currentLanguage == "ta") {
      switch (originalName.toLowerCase()) {
        case "tuna":
          return "சூரை மீன் (Tuna)";
        case "sardine":
          return "மத்தி மீன் (Sardine)";
        case "mackerel":
          return "கானாங்கெளுத்தி (Mackerel)";
        case "pomfret":
          return "வவ்வால் மீன் (Pomfret)";
        case "anchovy":
          return "நெத்திலி மீன் (Anchovy)";
        case "salmon":
          return "சால்மன் (Salmon)";
        default:
          return originalName;
      }
    } else if (_currentLanguage == "hi") {
      switch (originalName.toLowerCase()) {
        case "tuna":
          return "ट्यूना (Tuna)";
        case "sardine":
          return "तारली (Sardine)";
        case "mackerel":
          return "बांगड़ा (Mackerel)";
        case "pomfret":
          return "पॉपलेट (Pomfret)";
        case "anchovy":
          return "एंकोवी (Anchovy)";
        case "salmon":
          return "रावस (Salmon)";
        default:
          return originalName;
      }
    }
    return originalName;
  }

  // Trade Recommendation Translator Helper
  String translateTrade(String originalTrade) {
    if (_currentLanguage == "ta") {
      if (originalTrade.toUpperCase().contains("SELL")) return "இன்று விற்கவும்";
      if (originalTrade.toUpperCase().contains("WAIT")) return "1 நாள் காத்திருக்கவும்";
      if (originalTrade.toUpperCase().contains("NOT")) return "விற்க வேண்டாம்";
    } else if (_currentLanguage == "hi") {
      if (originalTrade.toUpperCase().contains("SELL")) return "आज ही बेचें";
      if (originalTrade.toUpperCase().contains("WAIT")) return "1 दिन रुकें";
      if (originalTrade.toUpperCase().contains("NOT")) return "न बेचें";
    }
    return originalTrade;
  }

  static const Map<String, Map<String, String>> _translations = {
    "en": {
      "home": "Home",
      "fish_zone": "Fish Zone",
      "sos": "SOS",
      "market": "Market",
      "profile": "Profile",
      "welcome_back": "Welcome back,",
      "captain": "Captain 👋",
      "safe_fishing": "Safe fishing starts here",
      "live_weather": "Live Ocean Weather",
      "quick_access": "⚓ Quick Access",
      "weather_title": "Weather",
      "weather_sub": "Live updates",
      "marine_doc_title": "Marine Doctor",
      "marine_doc_sub": "Health advisory",
      "fuel_title": "Fuel Optimizer",
      "fuel_sub": "Save fuel",
      "plastic_title": "Plastic Alert",
      "plastic_sub": "Keep sea clean",
      "notifications": "Maritime Alerts",
      "no_alerts": "No active notifications at this time.",
      "clear_all": "Clear All",
      "language_setting": "App Language",
      "privacy_policy": "Privacy Policy",
      "disclaimer": "Maritime Safety Disclaimer",
      "logout": "Logout",
      "version": "App Version v1.0.0 (Production Ready)",

      // Profile Field Labels
      "lbl_captain_name": "Captain Name",
      "lbl_phone_number": "Phone Number",
      "lbl_boat_id": "Boat Registration ID",
      "lbl_village": "Home Port / Village",

      // Weather Screen
      "temp": "Temperature",
      "humidity": "Humidity",
      "wind_speed": "Wind Speed",
      "wave_height": "Wave Height",
      "condition": "Condition",
      "refresh": "Refresh Weather Data",

      // Fish Zone Screen
      "pfz_title": "Potential Fishing Zone",
      "catch_probability": "Catch Probability",
      "catch_sub": "AI predicts fish concentration in this zone.",
      "target_species": "Target Species",
      "current_gps": "Current GPS Location",
      "ai_rec": "AI Recommendation",
      "distance": "Distance",
      "sea_state": "Sea State",

      // Fuel Screen
      "fuel_capacity": "Fuel Capacity (L)",
      "current_fuel": "Current Fuel Level (L)",
      "trip_distance": "Voyage Distance (km)",
      "consumption": "Consumption Rate (L/km)",
      "sea_condition": "Sea Condition",
      "calm": "Calm",
      "medium": "Medium",
      "rough": "Rough",
      "calc_fuel": "Calculate Fuel Safety",
      "route_opt_title": "AI Fuel-Optimized Route",
      "eco_route": "AI Eco-Current Route (Recommended)",
      "direct_route": "Direct High-Drag Route",
      "coastal_route": "Coastal Refuge Buffer Route",
      "fuel_saved": "Fuel Saved",
      "cost_saved": "Cost Saved",
      "safety_status": "Voyage Safety Status",
      "est_cost": "Estimated Fuel Cost",
      "safe_to_go": "SAFE TO GO",
      "return_soon": "RETURN SOON",
      "not_safe": "NOT SAFE",

      // Market Screen
      "market_intel": "Fish Market Rates",
      "price_per_kg": "Price / kg",
      "demand": "Market Demand",
      "high_demand": "HIGH",
      "medium_demand": "MEDIUM",
      "low_demand": "LOW",
      "recommendation": "AI Trade Advice",
      "top_catch": "Best Market Opportunity",

      // Plastic Screen
      "plastic_header": "Ocean Plastic Alert",
      "scan_image": "Scan Ocean Image",
      "take_photo": "Take Photo (Camera)",
      "choose_gallery": "Choose from Gallery",
      "plastic_detected": "Plastic Detected",
      "pollution_level": "Pollution Severity",
      "detected_objects": "Detected Waste Objects",
      "no_plastic": "No plastic debris detected in image.",
      "high": "HIGH",
      "low": "LOW",
      "yes": "YES",
      "no": "NO",

      // Marine Doctor Screen
      "doctor_header": "Marine Doctor Diagnostics",
      "record_sound": "Record Engine Sound",
      "analyzing": "Analyzing Engine Acoustics...",
      "health_score": "Confidence Score",
      "issue_detected": "Engine Status",
      "healthy": "Healthy / Normal",
      "warning": "Warning / Misalignment",

      // SOS Screen
      "sos_header": "Emergency SOS Safety",
      "tap_sos": "TAP FOR EMERGENCY SOS",
      "emergency_status": "Emergency Status",
      "standby": "Standby / Monitoring",
      "transmitting_gps": "Transmitting Live Coordinates",
      "voice_alert": "Voice Alert Monitor",
      "voice_sub": "Say HELP, SOS or EMERGENCY",
      "scream_detector": "Scream & Noise Detector",
      "scream_sub": "Auto SOS when scream detected",
      "latitude": "Latitude",
      "longitude": "Longitude",
    },

    "ta": {
      "home": "முகப்பு",
      "fish_zone": "மீன் வளம்",
      "sos": "அவசரம்",
      "market": "சந்தை",
      "profile": "சுயவிவரம்",
      "welcome_back": "மீண்டும் வருக,",
      "captain": "கேப்டன் 👋",
      "safe_fishing": "பாதுகாப்பான மீன்பிடித்தல் இங்கு தொடங்குகிறது",
      "live_weather": "நேரலை கடல் வானிலை",
      "quick_access": "⚓ விரைவு அணுகல்",
      "weather_title": "வானிலை",
      "weather_sub": "நேரலை தகவல்கள்",
      "marine_doc_title": "மரைன் டாக்டர்",
      "marine_doc_sub": "இயந்திர ஆலோசனை",
      "fuel_title": "எரிபொருள் மேலாண்மை",
      "fuel_sub": "எரிபொருள் சேமிப்பு",
      "plastic_title": "பிளாஸ்டிக் விழிப்புணர்வு",
      "plastic_sub": "கடலை சுத்தமாக வைக்கவும்",
      "notifications": "கடல்சார் அறிவிப்புகள்",
      "no_alerts": "தற்போது அறிவிப்புகள் எதுவும் இல்லை.",
      "clear_all": "அனைத்தையும் நீக்கு",
      "language_setting": "செயலி மொழி (App Language)",
      "privacy_policy": "தனியுரிமைக் கொள்கை",
      "disclaimer": "கடல் பாதுகாப்பு மறுப்பு",
      "logout": "வெளியேறு",
      "version": "செயலி பதிப்பு v1.0.0 (தயார் நிலை)",

      // Profile Field Labels
      "lbl_captain_name": "கேப்டன் பெயர்",
      "lbl_phone_number": "தொலைபேசி எண்",
      "lbl_boat_id": "படகுகளின் எண் (Boat ID)",
      "lbl_village": "துறைமுகம் / கிராமம்",

      // Weather Screen
      "temp": "வெப்பநிலை",
      "humidity": "ஈரப்பதம்",
      "wind_speed": "காற்றின் வேகம்",
      "wave_height": "அலை உயரம்",
      "condition": "கடல் நிலை",
      "refresh": "வானிலை புதுப்பித்தல்",

      // Fish Zone Screen
      "pfz_title": "மீன்பிடி வாய்ப்பு மண்டலம்",
      "catch_probability": "மீன் பிடிக்கும் வாய்ப்பு",
      "catch_sub": "இந்த பகுதியில் மீன் வளத்தை AI கணித்துள்ளது.",
      "target_species": "மீன் வகை",
      "current_gps": "தற்போதைய ஜிபிஎஸ் இடம்",
      "ai_rec": "செயற்கை நுண்ணறிவு ஆலோசனை",
      "distance": "தூரம்",
      "sea_state": "கடல் நிலை",

      // Fuel Screen
      "fuel_capacity": "எரிபொருள் கொள்ளளவு (லிட்டர்)",
      "current_fuel": "தற்போதைய எரிபொருள் (லிட்டர்)",
      "trip_distance": "பயண தூரம் (கி.மீ)",
      "consumption": "எரிபொருள் பயன்பாடு (லி/கிமீ)",
      "sea_condition": "கடல் நிலை",
      "calm": "அமைதி",
      "medium": "மிதமான",
      "rough": "சீற்றமான",
      "calc_fuel": "எரிபொருள் பாதுகாப்பு கணக்கீடு",
      "route_opt_title": "எரிபொருள் சிக்கனப் பாதை (AI Route)",
      "eco_route": "AI கடல் நீரோட்டப் பாதை (பரிந்துரை)",
      "direct_route": "நேரடிப் பாதை (அதிக உராய்வு)",
      "coastal_route": "கடற்கரை பாதுகாப்புப் பாதை",
      "fuel_saved": "சேமிக்கப்பட்ட எரிபொருள்",
      "cost_saved": "சேமிக்கப்பட்ட தொகை",
      "safety_status": "பயண பாதுகாப்பு நிலை",
      "est_cost": "எதிர்பார்க்கப்படும் செலவு",
      "safe_to_go": "பயணம் பாதுகாப்பானது",
      "return_soon": "விரைவில் திரும்புங்கள்",
      "not_safe": "பாதுகாப்பற்றது",

      // Market Screen
      "market_intel": "மீன் சந்தை நிலவரம்",
      "price_per_kg": "கிலோ விலை (ரூ)",
      "demand": "சந்தை தேவை",
      "high_demand": "அதிக தேவை",
      "medium_demand": "மிதமான தேவை",
      "low_demand": "குறைந்த தேவை",
      "recommendation": "வியாபார ஆலோசனை",
      "top_catch": "சிறந்த விற்பனை வாய்ப்பு",

      // Plastic Screen
      "plastic_header": "பிளாஸ்டிக் கழிவு விழிப்புணர்வு",
      "scan_image": "கடல் புகைப்படத்தை ஸ்கேன் செய்",
      "take_photo": "கேமரா மூலம் படம் எடு",
      "choose_gallery": "கேலரியில் இருந்து தேர்ந்தெடு",
      "plastic_detected": "பிளாஸ்டிக் கண்டறியப்பட்டது",
      "pollution_level": "மாசுபாட்டின் அளவு",
      "detected_objects": "கண்டறியப்பட்ட கழிவு பொருட்கள்",
      "no_plastic": "படப் பகுதியில் பிளாஸ்டிக் கழிவுகள் இல்லை.",
      "high": "அதிகம்",
      "low": "குறைவு",
      "yes": "ஆம்",
      "no": "இல்லை",

      // Marine Doctor Screen
      "doctor_header": "மரைன் டாக்டர் சோதனை",
      "record_sound": "இயந்திர ஒலியை பதிவு செய்",
      "analyzing": "இயந்திர ஒலியை பகுப்பாய்வு செய்கிறது...",
      "health_score": "இயந்திர ஆரோக்கிய நிலை",
      "issue_detected": "இயந்திர நிலைமை",
      "healthy": "நன்றாக இயங்குகிறது",
      "warning": "சோதனை தேவை",

      // SOS Screen
      "sos_header": "அவசர பாதுகாப்பு (SOS)",
      "tap_sos": "அவசர உதவிக்கு அழுத்தவும்",
      "emergency_status": "அவசர நிலைமை",
      "standby": "காத்திருப்பு நிலை",
      "transmitting_gps": "ஜிபிஎஸ் இருப்பிடம் அனுப்பப்படுகிறது",
      "voice_alert": "குரல் கண்காணிப்பு",
      "voice_sub": "HELP, SOS அல்லது எமர்ஜென்சி எனக் கூறவும்",
      "scream_detector": "அலறல் ஒலி கண்டறிதல்",
      "scream_sub": "அலறல் கேட்டால் தானியங்கி SOS",
      "latitude": "அட்சரேகை (Latitude)",
      "longitude": "தீர்க்கரேகை (Longitude)",
    },

    "hi": {
      "home": "होम",
      "fish_zone": "मछली क्षेत्र",
      "sos": "आपातकालीन",
      "market": "बाजार",
      "profile": "प्रोफाइल",
      "welcome_back": "वापसी पर स्वागत है,",
      "captain": "कप्तान 👋",
      "safe_fishing": "सुरक्षित मछली पकड़ना यहां से शुरू होता है",
      "live_weather": "लाइव समुद्री मौसम",
      "quick_access": "⚓ त्वरित पहुँच",
      "weather_title": "मौसम",
      "weather_sub": "लाइव अपडेट",
      "marine_doc_title": "मरीन डॉक्टर",
      "marine_doc_sub": "इंजन सलाह",
      "fuel_title": "ईंधन बचत",
      "fuel_sub": "ईंधन बचाएं",
      "plastic_title": "प्लास्टिक अलर्ट",
      "plastic_sub": "समुद्र साफ रखें",
      "notifications": "समुद्री अलर्ट",
      "no_alerts": "इस समय कोई अलर्ट नहीं है।",
      "clear_all": "सभी हटाएं",
      "language_setting": "ऐप भाषा (App Language)",
      "privacy_policy": "गोपनीयता नीति",
      "disclaimer": "समुद्री सुरक्षा अस्वीकरण",
      "logout": "लॉग आउट",
      "version": "ऐप संस्करण v1.0.0 (उत्पादन तैयार)",

      "lbl_captain_name": "कप्तान का नाम",
      "lbl_phone_number": "फोन नंबर",
      "lbl_boat_id": "नाव पंजीकरण आईडी",
      "lbl_village": "बंदरगाह / गांव",

      "temp": "तापमान",
      "humidity": "नमी",
      "wind_speed": "हवा की गति",
      "wave_height": "लहर की ऊंचाई",
      "condition": "मौसम की स्थिति",
      "refresh": "मौसम अपडेट करें",

      "pfz_title": "संभावित मछली क्षेत्र",
      "catch_probability": "पकड़ने की संभावना",
      "target_species": "मछली की प्रजाति",
      "advisory": "समुद्री मछली पकड़ने की सलाह",

      "fuel_capacity": "ईंधन क्षमता (लीटर)",
      "current_fuel": "वर्तमान ईंधन (लीटर)",
      "trip_distance": "यात्रा की दूरी (किमी)",
      "consumption": "ईंधन खपत",
      "sea_condition": "समुद्र की स्थिति",
      "calm": "शांत",
      "medium": "मध्यम",
      "rough": "खराब",
      "calculate_fuel": "ईंधन सुरक्षा जांचें",
      "safety_status": "यात्रा सुरक्षा स्थिति",
      "safe_to_go": "सुरक्षित यात्रा",

      "market_intel": "मछली बाजार दरें",
      "price_per_kg": "मूल्य / किग्रा",
      "demand": "बाजार की मांग",
      "high_demand": "उच्च मांग",
      "sell_today": "आज ही बेचें",

      "plastic_header": "प्लास्टिक कचरा अलर्ट",
      "scan_image": "समुद्र की फोटो स्कैन करें",
      "plastic_detected": "प्लास्टिक मिला",
      "pollution_level": "प्रदूषण का स्तर",
      "yes": "हाँ",
      "no": "नहीं",

      "doctor_header": "मरीन डॉक्टर जांच",
      "record_sound": "इंजन की आवाज रिकॉर्ड करें",
      "health_score": "इंजन स्वास्थ्य स्कोर",

      "sos_header": "आपातकालीन सहायता (SOS)",
      "tap_sos": "SOS बटन दबाएं",
      "emergency_status": "आपातकालीन स्थिति",
      "standby": "निगरानी जारी है",
      "voice_alert": "आवाज निगरानी",
      "scream_detector": "चिल्लाने की पहचान",
      "latitude": "अक्षांश (Latitude)",
      "longitude": "देशांतर (Longitude)",
    },
  };
}
