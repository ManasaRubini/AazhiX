import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'dart:async';

import '../services/sos_service.dart';
import '../services/app_language_provider.dart';

class SosScreen extends StatefulWidget {
  const SosScreen({super.key});

  @override
  State<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends State<SosScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  final FlutterTts tts = FlutterTts();
  final SpeechToText speech = SpeechToText();

  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _noiseSub;

  bool listening = false;
  bool screamDetectionActive = false;
  String status = "Standby";

  double latitude = 0;
  double longitude = 0;

  DateTime lastTrigger = DateTime.now().subtract(const Duration(minutes: 1));

  @override
  void initState() {
    super.initState();
    initializeSpeech();
  }

  Future<void> initializeSpeech() async {
    await Permission.microphone.request();
    await speech.initialize();
  }

  Future<void> triggerSOS() async {
    try {
      setState(() {
        status = "Fetching Location...";
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      final result = await SosService().triggerSOS(
        latitude,
        longitude,
      );

      await tts.speak("Emergency signal transmitted");

      setState(() {
        status = result["status"] ?? "SOS Sent";
      });
    } catch (e) {
      setState(() {
        status = "Failed";
      });
    }
  }

  Future<void> startVoiceSOS() async {
    setState(() {
      listening = true;
    });

    speech.listen(
      onResult: (result) {
        final text = result.recognizedWords.toLowerCase();

        if (text.contains("help") || text.contains("sos") || text.contains("emergency") || text.contains("ஆபத்து")) {
          triggerSOS();
        }
      },
    );
  }

  Future<void> startScreamDetection() async {
    await Permission.microphone.request();

    _noiseMeter = NoiseMeter();
    screamDetectionActive = true;

    _noiseSub = _noiseMeter!.noise.listen((NoiseReading reading) async {
      double db = reading.meanDecibel;

      if (db > 85) {
        await autoSOS();
      }
    });

    setState(() {
      status = "Scream detection ON";
    });
  }

  Future<void> autoSOS() async {
    if (DateTime.now().difference(lastTrigger).inSeconds < 30) return;

    lastTrigger = DateTime.now();

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      await SosService().triggerSOS(latitude, longitude);
      await tts.speak("Emergency detected. SOS sent.");

      setState(() {
        status = "AUTO SOS TRIGGERED";
      });
    } catch (e) {
      setState(() {
        status = "Auto SOS failed";
      });
    }
  }

  Widget infoRow(String title, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.cyanAccent,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _langProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xff041B43),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/sea_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.55),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// Header
                      Row(
                        children: [
                          const Icon(
                            Icons.sos,
                            color: Colors.redAccent,
                            size: 35,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _langProvider.getText("sos_header"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// SOS BUTTON
                      GestureDetector(
                        onTap: triggerSOS,
                        child: Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Colors.redAccent,
                                Colors.red,
                                Color(0xff8B0000),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(.8),
                                blurRadius: 40,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              _langProvider.getText("sos"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 55,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 30),

                      /// STATUS CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.shield,
                              color: Colors.cyanAccent,
                              size: 40,
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              "Emergency Status",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              status,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// Voice SOS
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orange.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.orange.withOpacity(.4),
                            ),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.mic,
                              color: Colors.orange,
                            ),
                            title: Text(
                              _langProvider.getText("voice_alert"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              listening ? "Listening..." : "Say HELP, SOS or EMERGENCY",
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                            onTap: startVoiceSOS,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

                      /// Scream Detection
                      Material(
                        color: Colors.transparent,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.withOpacity(.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.deepPurple.withOpacity(.4),
                            ),
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.hearing,
                              color: Colors.deepPurpleAccent,
                            ),
                            title: Text(
                              _langProvider.getText("scream_detector"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              screamDetectionActive ? "Monitoring microphone..." : "Auto SOS when scream detected",
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
                            onTap: startScreamDetection,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// LOCATION CARD
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  color: Colors.cyanAccent,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _langProvider.getText("current_gps"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            infoRow(
                              "Latitude",
                              latitude.toStringAsFixed(5),
                            ),
                            const SizedBox(height: 10),
                            infoRow(
                              "Longitude",
                              longitude.toStringAsFixed(5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    speech.stop();
    _noiseSub?.cancel();
    super.dispose();
  }
}