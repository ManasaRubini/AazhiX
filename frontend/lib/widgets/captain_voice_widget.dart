import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../services/captain_voice_service.dart';

class CaptainVoiceWidget extends StatefulWidget {
  const CaptainVoiceWidget({super.key});

  @override
  State<CaptainVoiceWidget> createState() => _CaptainVoiceWidgetState();
}

class _CaptainVoiceWidgetState extends State<CaptainVoiceWidget> {
  final SpeechToText _speech = SpeechToText();
  final CaptainVoiceService _voiceService = CaptainVoiceService();

  bool _isListening = false;
  bool _isProcessing = false;
  String _recognizedText = "";
  String _selectedLanguage = "en";
  Map<String, dynamic>? _lastResponse;

  final Map<String, String> _languages = {
    "en": "🇬🇧 English",
    "ta": "🇮🇳 தமிழ் (Tamil)",
    "hi": "🇮🇳 हिंदी (Hindi)",
    "ml": "🇮🇳 മലയാളം (Malayalam)",
    "te": "🇮🇳 తెలుగు (Telugu)",
  };

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    try {
      await Permission.microphone.request();
      await _speech.initialize();
    } catch (e) {
      print("Speech init note: $e");
    }
  }

  Future<void> _processQuery(String text) async {
    if (text.trim().isEmpty) return;

    setState(() {
      _isListening = false;
      _isProcessing = true;
      _recognizedText = text;
    });

    try {
      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 3));
      } catch (_) {}

      final result = await _voiceService.sendVoiceQuery(
        query: text,
        latitude: pos?.latitude,
        longitude: pos?.longitude,
        language: _selectedLanguage,
      );

      if (!mounted) return;

      setState(() {
        _lastResponse = result;
        _isProcessing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _startListening() async {
    await _voiceService.stopSpeaking();
    bool available = await _speech.initialize();

    if (available) {
      setState(() {
        _isListening = true;
        _recognizedText = _getListeningPrompt(_selectedLanguage);
      });

      _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          if (result.finalResult) {
            _processQuery(result.recognizedWords);
          }
        },
      );
    } else {
      setState(() {
        _recognizedText = "Microphone unavailable";
      });
    }
  }

  String _getListeningPrompt(String lang) {
    switch (lang) {
      case "ta":
        return "கேளுங்கள் கேப்டன்... (Listening in Tamil)";
      case "hi":
        return "बोलिए कप्तान... (Listening in Hindi)";
      case "ml":
        return "പറയൂ ക്യാപ്റ്റൻ... (Listening in Malayalam)";
      case "te":
        return "చెప్పండి కెప్టెన్... (Listening in Telugu)";
      default:
        return "Listening for Captain's voice...";
    }
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  List<Map<String, String>> _getPillsForLanguage(String lang) {
    if (lang == "ta") {
      return [
        {"label": "🌊 இன்று அலை உயரம் எவ்வளவு?", "query": "இன்று அலை உயரம் எவ்வளவு"},
        {"label": "⛽ என் எரிபொருள் பாதுகாப்பானதா?", "query": "என் எரிபொருள் பாதுகாப்பானதா"},
        {"label": "🐟 மீன் மண்டலம் எங்கே உள்ளது?", "query": "மீன் மண்டலம் எங்கே உள்ளது"},
        {"label": "📈 சூரை மீன் விலை என்ன?", "query": "சூரை மீன் விலை என்ன"},
        {"label": "🚨 ஆபத்து SOS எமர்ஜென்சி", "query": "ஆபத்து SOS எமர்ஜென்சி"},
      ];
    } else if (lang == "hi") {
      return [
        {"label": "🌊 आज लहरों की ऊंचाई क्या है?", "query": "आज लहरों की ऊंचाई क्या है"},
        {"label": "⛽ क्या मेरा ईंधन सुरक्षित है?", "query": "क्या मेरा ईंधन सुरक्षित है"},
        {"label": "🐟 निकटतम मछली क्षेत्र कहाँ है?", "query": "निकटतम मछली क्षेत्र कहाँ है"},
        {"label": "📈 ट्यूना मछली का भाव क्या है?", "query": "ट्यूना मछली का भाव क्या है"},
        {"label": "🚨 आपातकालीन SOS", "query": "आपातकालीन SOS"},
      ];
    }
    return [
      {"label": "🌊 What's the wave height today?", "query": "what is the wave height today"},
      {"label": "⛽ Am I safe on fuel?", "query": "am I safe on fuel"},
      {"label": "🐟 Where is the nearest fish zone?", "query": "where is the nearest fish zone"},
      {"label": "📈 What is the market price of Tuna?", "query": "what is the market price of Tuna"},
      {"label": "🚨 Emergency SOS", "query": "emergency SOS"},
    ];
  }

  void openAssistantModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final pills = _getPillsForLanguage(_selectedLanguage);

            return Container(
              height: MediaQuery.of(context).size.height * 0.78,
              decoration: const BoxDecoration(
                color: Color(0xff061A3A),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.cyan,
                    blurRadius: 25,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(22),
              child: Column(
                children: [
                  /// HANDLE BAR
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// HEADER & LANGUAGE SELECTOR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.record_voice_over, color: Colors.cyanAccent, size: 28),
                          SizedBox(width: 8),
                          Text(
                            "AazhiX Voice AI",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(0.4)),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            dropdownColor: const Color(0xff0A2246),
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            icon: const Icon(Icons.arrow_drop_down, color: Colors.cyanAccent),
                            items: _languages.entries.map((e) {
                              return DropdownMenuItem<String>(
                                value: e.key,
                                child: Text(e.value),
                              );
                            }).toList(),
                            onChanged: (newLang) {
                              if (newLang != null) {
                                setModalState(() {
                                  _selectedLanguage = newLang;
                                });
                                setState(() {
                                  _selectedLanguage = newLang;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// MIC ANIMATED BUTTON
                  GestureDetector(
                    onTap: () async {
                      if (_isListening) {
                        await _stopListening();
                      } else {
                        await _startListening();
                      }
                      setModalState(() {});
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: _isListening
                              ? [Colors.redAccent, Colors.red]
                              : [Colors.cyan, Colors.blueAccent],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_isListening ? Colors.red : Colors.cyan).withOpacity(0.6),
                            blurRadius: 30,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isListening ? Icons.mic : Icons.mic_none,
                        size: 55,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    _isListening
                        ? "Listening... Speak now Captain"
                        : _isProcessing
                            ? "Gemini AI is generating voice response..."
                            : "Tap mic or choose a native command pill",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 18),

                  /// TRANSCRIPTION & RESPONSE AREA
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_recognizedText.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                "\"$_recognizedText\"",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 15,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),

                          if (_lastResponse != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(18),
                              decoration: BoxDecoration(
                                color: const Color(0xff122E58),
                                borderRadius: BorderRadius.circular(22),
                                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.psychology, color: Colors.cyanAccent),
                                      const SizedBox(width: 8),
                                      Text(
                                        _lastResponse!["title"] ?? "Gemini AI",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    _lastResponse!["spoken_response"] ?? "",
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 15,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 18),
                          ],

                          /// NATIVE SUGGESTED COMMAND PILLS
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Suggested Captain Commands",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: pills.map((p) {
                              return quickPill(p["label"]!, () {
                                _processQuery(p["query"]!);
                                setModalState(() {});
                              });
                            }).toList(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget quickPill(String text, VoidCallback onTap) {
    return ActionChip(
      onPressed: onTap,
      backgroundColor: Colors.white.withOpacity(0.12),
      side: const BorderSide(color: Colors.cyanAccent),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: openAssistantModal,
      backgroundColor: Colors.cyan,
      elevation: 10,
      child: const Icon(
        Icons.mic,
        color: Colors.white,
        size: 32,
      ),
    );
  }
}
