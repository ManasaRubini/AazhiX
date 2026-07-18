import 'dart:async';
import 'package:noise_meter/noise_meter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScreamDetector {
  NoiseMeter? _noiseMeter;
  StreamSubscription<NoiseReading>? _subscription;

  bool isActive = false;
  DateTime lastTrigger = DateTime.now().subtract(Duration(minutes: 1));

  final String backendUrl = "http://YOUR_IP:8000/api/sos/";

  Future<void> start() async {
    if (await Permission.microphone.request().isDenied) {
      return;
    }

    _noiseMeter = NoiseMeter();
    isActive = true;

    _subscription = _noiseMeter!.noise.listen((NoiseReading reading) {
      double db = reading.meanDecibel;

      print("Noise: $db");

      if (db > 85) {
        _triggerSOS();
      }
    });
  }

  Future<void> _triggerSOS() async {
    if (!isActive) return;

    // cooldown (avoid spam)
    if (DateTime.now().difference(lastTrigger).inSeconds < 30) return;

    lastTrigger = DateTime.now();
    isActive = false;

    try {
      await http.post(
        Uri.parse(backendUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "trigger": "scream_detected",
          "latitude": 10.78,
          "longitude": 79.23
        }),
      );

      print("🚨 SOS SENT FROM SCREAM");
    } catch (e) {
      print("Error sending SOS: $e");
    }

    // re-enable after delay
    Future.delayed(Duration(seconds: 10), () {
      isActive = true;
    });
  }

  void stop() {
    _subscription?.cancel();
    isActive = false;
  }
}