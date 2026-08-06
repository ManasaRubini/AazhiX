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
          status = result["status"];
          confidence = result["confidence"];
          recommendation = result["recommendation"];
        });
      }
    } catch (e) {
      print("ERROR: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    Color statusColor = status == "Healthy"
        ? Colors.greenAccent
        : status == "Minor Issue"
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
                        Row(
                          children: [
                            const Icon(
                              Icons.engineering,
                              color: Colors.cyanAccent,
                              size: 35,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              _langProvider.getText("doctor_header"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 35),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 500),
                          width: 180,
                          height: 180,
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
                            size: 80,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          isRecording
                              ? _langProvider.getText("analyzing")
                              : "Ready For Diagnosis",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                          width: double.infinity,
                          height: 65,
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
                              isRecording ? "Stop Recording" : _langProvider.getText("record_sound"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.health_and_safety,
                                color: statusColor,
                                size: 40,
                              ),
                              const SizedBox(width: 15),
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
                                    const SizedBox(height: 5),
                                    Text(
                                      status == "Healthy" ? _langProvider.getText("healthy") : status,
                                      style: TextStyle(
                                        color: statusColor,
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 15),
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              color: Colors.white24,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.speed,
                                color: Colors.cyanAccent,
                                size: 40,
                              ),
                              const SizedBox(width: 15),
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
                                    const SizedBox(height: 5),
                                    Text(
                                      "$confidence %",
                                      style: const TextStyle(
                                        color: Colors.cyanAccent,
                                        fontSize: 28,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(25),
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
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 15),
                              Text(
                                recommendation,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.6,
                                  fontSize: 15,
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