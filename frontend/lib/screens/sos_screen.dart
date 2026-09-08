import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:noise_meter/noise_meter.dart';
import 'package:url_launcher/url_launcher.dart';
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
    try {
      await Permission.microphone.request();
      await speech.initialize();
    } catch (_) {}
  }

  Future<void> triggerSOS() async {
    try {
      setState(() {
        status = "Fetching Location...";
      });

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 4));

      latitude = position.latitude;
      longitude = position.longitude;

      final result = await SosService().triggerSOS(
        latitude,
        longitude,
      );

      await tts.speak("Emergency signal transmitted");

      if (!mounted) return;
      setState(() {
        status = result["status"] ?? "SOS Sent";
      });
    } catch (e) {
      if (!mounted) return;
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

      if (!mounted) return;
      setState(() {
        status = "AUTO SOS TRIGGERED";
      });
    } catch (e) {
      if (!mounted) return;
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
                      /// Header (WRAPPED IN EXPANDED TO PREVENT OVERFLOW BANNER)
                      Row(
                        children: [
                          const Icon(
                            Icons.sos,
                            color: Colors.redAccent,
                            size: 35,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _langProvider.getText("sos_header"),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 25),

                      /// SOS BUTTON
                      GestureDetector(
                        onTap: triggerSOS,
                        child: Container(
                          width: 200,
                          height: 200,
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
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                _langProvider.getText("sos"),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

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
                              size: 38,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _langProvider.getText("emergency_status"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              status == "Standby" ? _langProvider.getText("standby") : status,
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 15),

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
                              listening ? "Listening..." : _langProvider.getText("voice_sub"),
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
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
                              screamDetectionActive ? "Monitoring..." : _langProvider.getText("scream_sub"),
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                              size: 16,
                            ),
                            onTap: startScreamDetection,
                          ),
                        ),
                      ),

                      const SizedBox(height: 15),

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
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            infoRow(
                              _langProvider.getText("latitude"),
                              latitude.toStringAsFixed(5),
                            ),
                            const SizedBox(height: 10),
                            infoRow(
                              _langProvider.getText("longitude"),
                              longitude.toStringAsFixed(5),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 📞 FFMA MARITIME EMERGENCY CONTACTS DIRECTORY
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.contact_phone, color: Colors.amberAccent, size: 24),
                                SizedBox(width: 10),
                                Text(
                                  "Maritime Helpline Directory",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            contactTile("Indian Coast Guard (Toll Free)", "1554", Icons.shield, Colors.redAccent),
                            contactTile("Coastal Security Police", "1093", Icons.local_police, Colors.orangeAccent),
                            contactTile("Fisheries Department Helpline", "18004251660", Icons.phishing, Colors.greenAccent),
                            contactTile("Marine Ambulance Emergency", "108", Icons.medical_services, Colors.cyanAccent),
                            contactTile("Nagapattinam Harbor Control", "04365222400", Icons.anchor, Colors.amberAccent),
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

  Widget contactTile(String title, String number, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(.2),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
        ),
        subtitle: Text(
          "Tel: $number",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.phone_in_talk, color: Colors.greenAccent),
          onPressed: () async {
            final uri = Uri.parse("tel:$number");
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri);
            }
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    speech.stop();
    _noiseSub?.cancel();
    super.dispose();
  }
}