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
  Map<String, dynamic>? _lastResponse;

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
        _recognizedText = "Listening for Captain's voice...";
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

  Future<void> _stopListening() async {
    await _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  void openAssistantModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * 0.72,
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
              padding: const EdgeInsets.all(24),
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

                  const SizedBox(height: 20),

                  /// HEADER
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.record_voice_over, color: Colors.cyanAccent, size: 30),
                          SizedBox(width: 10),
                          Text(
                            "AazhiX Voice Assistant",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        onPressed: () {
                          _voiceService.stopSpeaking();
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.close, color: Colors.white70),
                      ),
                    ],
                  ),

                  const SizedBox(height: 25),

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
                      width: 120,
                      height: 120,
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
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  Text(
                    _isListening
                        ? "Listening... Speak now Captain"
                        : _isProcessing
                            ? "AI Assistant is thinking..."
                            : "Tap mic or select a quick voice command",
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TRANSCRIPTION & RESPONSE AREA
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          if (_recognizedText.isNotEmpty)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              margin: const EdgeInsets.only(bottom: 15),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Text(
                                "\"$_recognizedText\"",
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontSize: 16,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),

                          if (_lastResponse != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: const Color(0xff122E58),
                                borderRadius: BorderRadius.circular(25),
                                border: Border.all(color: Colors.cyanAccent.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.volume_up, color: Colors.cyanAccent),
                                      const SizedBox(width: 10),
                                      Text(
                                        _lastResponse!["title"] ?? "AI Response",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
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
                            const SizedBox(height: 20),
                          ],

                          /// QUICK VOICE COMMAND PILLS
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Suggested Captain Commands",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),

                          Wrap(
                            spacing: 10,
                            runSpacing: 10,
                            children: [
                              quickPill("🌊 What's the wave height today?", () {
                                _processQuery("what is the wave height today");
                                setModalState(() {});
                              }),
                              quickPill("⛽ Am I safe on fuel?", () {
                                _processQuery("am I safe on fuel");
                                setModalState(() {});
                              }),
                              quickPill("🐟 Where is the nearest fish zone?", () {
                                _processQuery("where is the nearest fish zone");
                                setModalState(() {});
                              }),
                              quickPill("📈 What is the market price of Tuna?", () {
                                _processQuery("what is the market price of Tuna");
                                setModalState(() {});
                              }),
                              quickPill("🚨 Emergency SOS", () {
                                _processQuery("emergency SOS");
                                setModalState(() {});
                              }),
                            ],
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
          fontSize: 13,
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
