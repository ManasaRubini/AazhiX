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
      "language_setting": "App Language / மொழி",
      "privacy_policy": "Privacy Policy",
      "disclaimer": "Maritime Safety Disclaimer",
      "logout": "Logout",
      "version": "App Version v1.0.0 (Production Ready)",

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
      "target_species": "Target Species",
      "current_gps": "Current GPS Location",
      "advisory": "Ocean Fishing Advisory",

      // Fuel Screen
      "fuel_capacity": "Fuel Capacity (L)",
      "current_fuel": "Current Fuel Level (L)",
      "distance": "Voyage Distance (km)",
      "consumption": "Consumption (L/km)",
      "sea_condition": "Sea Condition",
      "calm": "Calm",
      "medium": "Medium",
      "rough": "Rough",
      "calculate_fuel": "Calculate Fuel Safety",
      "safety_status": "Voyage Safety Status",
      "est_cost": "Estimated Fuel Cost",
      "safe_to_go": "SAFE TO GO",
      "return_soon": "RETURN SOON",
      "not_safe": "NOT SAFE",

      // Market Screen
      "market_intel": "Fish Market Rates",
      "price_per_kg": "Price / kg",
      "demand": "Market Demand",
      "high_demand": "High Demand",
      "medium_demand": "Medium Demand",
      "low_demand": "Low Demand",
      "recommendation": "Trading Advice",
      "sell_today": "SELL TODAY",
      "wait_1_day": "WAIT 1 DAY",
      "do_not_sell": "DO NOT SELL",

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
      "health_score": "Engine Health Score",
      "issue_detected": "Engine Status",
      "healthy": "Healthy / Normal",
      "warning": "Warning / Misalignment",

      // SOS Screen
      "sos_header": "Emergency Distress (SOS)",
      "tap_sos": "TAP FOR EMERGENCY SOS",
      "transmitting_gps": "Transmitting Live Coordinates",
      "voice_alert": "Voice Alert Monitor",
      "scream_detector": "High Noise / Scream Detector",
      "coast_guard": "Nagapattinam Coast Guard",
    },

    "ta": {
      "home": "முகப்பு",
      "fish_zone": "மீன் மண்டலம்",
      "sos": "அவசரம் (SOS)",
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
      "fuel_title": "எரிபொருள் மேம்பாடு",
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
      "target_species": "மீன் வகை",
      "current_gps": "தற்போதைய ஜிபிஎஸ் இடம்",
      "advisory": "கடல் மீன்பிடி ஆலோசனை",

      // Fuel Screen
      "fuel_capacity": "எரிபொருள் கொள்ளளவு (லிட்டர்)",
      "current_fuel": "தற்போதைய எரிபொருள் (லிட்டர்)",
      "distance": "பயண தூரம் (கி.மீ)",
      "consumption": "எரிபொருள் பயன்பாடு (லி/கிமீ)",
      "sea_condition": "கடல் நிலை",
      "calm": "அமைதி",
      "medium": "மிதமான",
      "rough": "சீற்றமான",
      "calculate_fuel": "எரிபொருள் பாதுகாப்பு கணக்கீடு",
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
      "sell_today": "இன்று விற்கவும்",
      "wait_1_day": "1 நாள் காத்திருக்கவும்",
      "do_not_sell": "விற்க வேண்டாம்",

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
      "doctor_header": "மரைன் டாக்டர் இயந்திர சோதனை",
      "record_sound": "இயந்திர ஒலியை பதிவு செய்",
      "analyzing": "இயந்திர ஒலியை பகுப்பாய்வு செய்கிறது...",
      "health_score": "இயந்திர ஆரோக்கிய நிலை",
      "issue_detected": "இயந்திர நிலைமை",
      "healthy": "நன்றாக இயங்குகிறது",
      "warning": "சோதனை தேவை",

      // SOS Screen
      "sos_header": "அவசர பாதுகாப்பு (SOS)",
      "tap_sos": "அவசர உதவிக்கு அழுத்தவும்",
      "transmitting_gps": "ஜிபிஎஸ் இருப்பிடம் அனுப்பப்படுகிறது",
      "voice_alert": "குரல் கண்காணிப்பு",
      "scream_detector": "அலறல் ஒலி கண்டறிதல்",
      "coast_guard": "நாகப்பட்டினம் கடலோரக் காவல் படை",
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

      "temp": "तापमान",
      "humidity": "नमी",
      "wind_speed": "हवा की गति",
      "wave_height": "लहर की ऊंचाई",
      "condition": "मौसम की स्थिति",
      "refresh": "मौसम अपडेट करें",

      "pfz_title": "संभावित मछली पकड़ने का क्षेत्र",
      "catch_probability": "पकड़ने की संभावना",
      "target_species": "मछली की प्रजाति",
      "advisory": "समुद्री मछली पकड़ने की सलाह",

      "fuel_capacity": "ईंधन क्षमता (लीटर)",
      "current_fuel": "वर्तमान ईंधन (लीटर)",
      "distance": "यात्रा की दूरी (किमी)",
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
      "coast_guard": "भारतीय तटरक्षक",
    },
    "ml": {
      "home": "ഹോം",
      "fish_zone": "മത്സ്യ മേഖല",
      "sos": "അടിയന്തരം",
      "market": "മാർക്കറ്റ്",
      "profile": "പ്രൊഫൈൽ",
      "welcome_back": "വീണ്ടും സ്വാഗതം,",
      "captain": "ക്യാപ്റ്റൻ 👋",
      "safe_fishing": "സുരക്ഷിതമായ മീൻപിടുത്തം ഇവിടെ ആരംഭിക്കുന്നു",
      "live_weather": "തത്സമയ കടൽ കാലാവസ്ഥ",
      "quick_access": "⚓ ദ്രുത പ്രവേശനം",
      "weather_title": "കാലാവസ്ഥ",
      "weather_sub": "തത്സമയ വിവരങ്ങൾ",
      "marine_doc_title": "മറൈൻ ഡോക്ടർ",
      "marine_doc_sub": "എഞ്ചിൻ ഉപദേശം",
      "fuel_title": "ഇന്ധന ലാഭം",
      "fuel_sub": "ഇന്ധനം ലാഭിക്കൂ",
      "plastic_title": "പ്ലാസ്റ്റിക് ജാഗ്രത",
      "plastic_sub": "കടൽ ശുചിയാക്കുക",
      "notifications": "കടൽ അറിയിപ്പുകൾ",
      "no_alerts": "ഇപ്പോൾ പുതിയ അറിയിപ്പുകൾ ഇല്ല.",
      "clear_all": "എല്ലാം ഒഴിവാക്കുക",
      "language_setting": "ആപ്പ് ഭാഷ",
      "privacy_policy": "സ്വകാര്യതാ നയം",
      "disclaimer": "സുരക്ഷാ മുന്നറിയിപ്പ്",
      "logout": "ലോഗ് ഔട്ട്",
      "version": "ആപ്പ് പതിപ്പ് v1.0.0",

      "temp": "താപനില",
      "humidity": "ഈർപ്പം",
      "wind_speed": "കാറ്റിന്റെ വേഗത",
      "wave_height": "തിരമാല ഉയരം",
      "refresh": "കാലാവസ്ഥ വിവരങ്ങൾ പുതുക്കുക",

      "pfz_title": "മത്സ്യ ബന്ധന മേഖല",
      "catch_probability": "സാധ്യത",
      "advisory": "ഉപദേശം",

      "fuel_capacity": "ഇന്ധന അളവ്",
      "calculate_fuel": "ഇന്ധന സുരക്ഷ പരിശോധിക്കുക",
      "safe_to_go": "സുരക്ഷിതം",

      "market_intel": "മത്സ്യ വിപണി നിരക്ക്",
      "sell_today": "ഇന്ന് വിൽക്കുക",

      "plastic_header": "പ്ലാസ്റ്റിക് ജാഗ്രത",
      "scan_image": "ചിത്രം സ്കാൻ ചെയ്യുക",

      "doctor_header": "മറൈൻ ഡോക്ടർ",
      "record_sound": "എഞ്ചിൻ ശബ്ദം റെക്കോർഡ് ചെയ്യുക",

      "sos_header": "അടിയന്തര സഹായം (SOS)",
      "coast_guard": "കോസ്റ്റ് ഗാർഡ്",
    },
    "te": {
      "home": "హోమ్",
      "fish_zone": "చేపల జోన్",
      "sos": "అత్యవసరం",
      "market": "మార్కెట్",
      "profile": "ప్రొఫైల్",
      "welcome_back": "స్వాగతం,",
      "captain": "కెప్టెన్ 👋",
      "safe_fishing": "సురక్షితమైన వేట ఇక్కడే ప్రారంభమవుతుంది",
      "live_weather": "లైవ్ సముద్ర వాతావరణం",
      "quick_access": "⚓ త్వరిత ప్రవేశం",
      "weather_title": "వాతావరణం",
      "weather_sub": "లైవ్ సమాచారం",
      "marine_doc_title": "మెరైన్ డాక్టర్",
      "marine_doc_sub": "ఇంజిన్ సలహా",
      "fuel_title": "ఇంధన ఆదా",
      "fuel_sub": "ఇంధనం ఆదా చేయండి",
      "plastic_title": "ప్లాస్టిక్ హెచ్చరిక",
      "plastic_sub": "సముద్రాన్ని పరిశుభ్రంగా ఉంచండి",
      "notifications": "సముద్ర హెచ్చరికలు",
      "no_alerts": "ప్రస్తుతం ఎటువంటి హెచ్చరికలు లేవు.",
      "clear_all": "అన్నీ తొలగించండి",
      "language_setting": "యాప్ భాష",
      "privacy_policy": "గోప్యతా విధానం",
      "disclaimer": "సముద్ర భద్రతా నిరాకరణ",
      "logout": "లాగ్ అవుట్",
      "version": "యాప్ వెర్షన్ v1.0.0",

      "temp": "ఉష్ణోగ్రత",
      "humidity": "తేమ",
      "wind_speed": "గాలి వేగం",
      "wave_height": "అలల ఎత్తు",
      "refresh": "వాతావరణం నవీకరించు",

      "pfz_title": "చేపల వేట జోన్",
      "catch_probability": "చేపలు దొరికే అవకాశం",
      "advisory": "సముద్ర సలహా",

      "fuel_capacity": "ఇంధన సామర్థ్యం",
      "calculate_fuel": "ఇంధన భద్రత లెక్కించు",
      "safe_to_go": "సురక్షితం",

      "market_intel": "చేపల మార్కెట్ ధరలు",
      "sell_today": "ఈరోజు అమ్మండి",

      "plastic_header": "ప్లాస్టిక్ వ్యర్థాల హెచ్చరిక",
      "scan_image": "ఫొటో స్కాన్ చేయండి",

      "doctor_header": "మెరైన్ డాక్టర్",
      "record_sound": "ఇంజిన్ శబ్దం రికార్డు చేయండి",

      "sos_header": "అత్యవసర సహాయం (SOS)",
      "coast_guard": "కోస్ట్ గార్డ్",
    },
  };
}
