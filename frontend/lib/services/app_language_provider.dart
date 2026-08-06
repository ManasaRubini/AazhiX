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
    },
  };
}
