import 'package:flutter/material.dart';
import 'package:record/record.dart';
import '../services/audio_service.dart';
import '../services/app_language_provider.dart';
import 'package:path_provider/path_provider.dart';

class MarineDoctorScreen extends StatefulWidget {
  const MarineDoctorScreen({super.key});

  @override
  State<MarineDoctorScreen> createState() => _MarineDoctorScreenState();
}

class _MarineDoctorScreenState extends State<MarineDoctorScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  final AudioRecorder recorder = AudioRecorder();

  bool isRecording = false;
  String status = "Not analyzed";
  int confidence = 0;
  String recommendation = "Record engine sound to analyze engine health.";

  Future<void> startRecording() async {
    try {
      if (await recorder.hasPermission()) {
        final dir = await getTemporaryDirectory();
        final path = '${dir.path}/engine_sound.m4a';

        await recorder.start(
          const RecordConfig(),
          path: path,
        );

        setState(() {
          isRecording = true;
        });
      }
    } catch (e) {
      print("Recording error: $e");
    }
  }

  Future<void> stopRecording() async {
    try {
      final path = await recorder.stop();

      setState(() {
        isRecording = false;
      });

      if (path != null) {
        final result = await AudioService().analyzeAudio(path);

        if (!mounted) return;

        setState(() {
          status = result["status"] ?? "Healthy";
          confidence = result["confidence"] ?? 90;
          recommendation = result["recommendation"] ?? "Engine operating normally";
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == "Healthy" || status == "ஆரோக்கியமானது"
        ? Colors.greenAccent
        : status == "Minor Issue" || status == "Warning"
            ? Colors.orangeAccent
            : Colors.redAccent;

    return AnimatedBuilder(
      animation: _langProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.fromARGB(255, 8, 39, 93),
                  Color.fromARGB(255, 14, 68, 129),
                  Color.fromARGB(255, 13, 121, 171),
                ],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        /// HEADER (WRAPPED IN EXPANDED TO ELIMINATE OVERFLOW BANNER)
                        Row(
                          children: [
                            const Icon(
                              Icons.engineering,
                              color: Colors.cyanAccent,
                              size: 32,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                _langProvider.getText("doctor_header"),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 30),

                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 170,
                          height: 170,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                isRecording ? Colors.redAccent : Colors.greenAccent,
                                isRecording ? Colors.red : Colors.green,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: (isRecording ? Colors.red : Colors.green).withOpacity(.6),
                                blurRadius: 35,
                                spreadRadius: 5,
                              ),
                            ],
                          ),
                          child: Icon(
                            isRecording ? Icons.mic : Icons.settings,
                            size: 75,
                            color: Colors.white,
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          isRecording
                              ? _langProvider.getText("analyzing")
                              : status == "Not analyzed"
                                  ? "Ready For Diagnosis"
                                  : status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 60,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: isRecording ? Colors.red : Colors.green,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            onPressed: () {
                              if (isRecording) {
                                stopRecording();
                              } else {
                                startRecording();
                              }
                            },
                            icon: Icon(
                              isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                            ),
                            label: Text(
                              isRecording
                                  ? (_langProvider.currentLanguage == "ta" ? "பதிவை நிறுத்து" : "Stop Recording")
                                  : _langProvider.getText("record_sound"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 25),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                color: statusColor,
                                size: 38,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _langProvider.getText("issue_detected"),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      status == "Not analyzed"
                                          ? (_langProvider.currentLanguage == "ta" ? "பகுப்பாய்வு செய்யப்படவில்லை" : "Not analyzed")
                                          : status == "Healthy"
                                              ? _langProvider.getText("healthy")
                                              : status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 14),

                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.speed,
                                color: Colors.cyanAccent,
                                size: 38,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _langProvider.getText("health_score"),
                                      style: const TextStyle(
                                        color: Colors.white70,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "$confidence %",
                                      style: const TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 26,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.psychology,
                                    color: Colors.cyanAccent,
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    _langProvider.getText("recommendation"),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                recommendation == "Record engine sound to analyze engine health."
                                    ? (_langProvider.currentLanguage == "ta"
                                        ? "இயந்திர ஆரோக்கியத்தை பகுப்பாய்வு செய்ய இயந்திர ஒலியை பதிவு செய்யவும்."
                                        : recommendation)
                                    : recommendation,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.5,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}