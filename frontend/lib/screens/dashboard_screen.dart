import 'package:flutter/material.dart';
import '../services/scream_detector.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  // 🚨 Scream detection service
  final ScreamDetector detector = ScreamDetector();

  bool isListening = false;

  @override
  void initState() {
    super.initState();
    _startScreamDetection();
  }

  void _startScreamDetection() async {
    await detector.start();

    setState(() {
      isListening = true;
    });
  }

  void _stopScreamDetection() {
    detector.stop();

    setState(() {
      isListening = false;
    });
  }

  @override
  void dispose() {
    detector.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff0A1628),

      appBar: AppBar(
        backgroundColor: const Color(0xff0A1628),
        title: const Text(
          "AazhiX Voice Guard",
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            // 🔵 Status Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(
                    isListening ? Icons.mic : Icons.mic_off,
                    size: 60,
                    color: isListening ? Colors.green : Colors.red,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isListening
                        ? "Listening for emergency sounds..."
                        : "Scream detection stopped",
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // 🔘 Control Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  onPressed: () {
                    _startScreamDetection();
                  },
                  child: const Text("Start"),
                ),

                const SizedBox(width: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    _stopScreamDetection();
                  },
                  child: const Text("Stop"),
                ),
              ],
            ),

            const SizedBox(height: 40),

            const Text(
              "🚨 SOS will trigger automatically if scream is detected",
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}