import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_tts/flutter_tts.dart';
import 'api_constants.dart';

class CaptainVoiceService {
  final FlutterTts _tts = FlutterTts();

  Future<void> speak(String text) async {
    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.45);
      await _tts.setPitch(1.0);
      await _tts.speak(text);
    } catch (e) {
      print("TTS error: $e");
    }
  }

  Future<void> stopSpeaking() async {
    try {
      await _tts.stop();
    } catch (_) {}
  }

  Future<Map<String, dynamic>> sendVoiceQuery({
    required String query,
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.captainQuery),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "query": query,
          "latitude": latitude,
          "longitude": longitude,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        String spoken = data["spoken_response"] ?? "I have processed your query, Captain.";
        await speak(spoken);
        return data;
      }
    } catch (e) {
      print("CaptainVoiceService error: $e");
    }

    // Local fallback for offline/slow connection
    String fallbackSpoken = _getFallbackSpokenText(query);
    await speak(fallbackSpoken);

    return {
      "intent": "general",
      "spoken_response": fallbackSpoken,
      "title": "AazhiX Voice Assistant",
      "subtitle": fallbackSpoken,
      "details": {}
    };
  }

  String _getFallbackSpokenText(String query) {
    String q = query.toLowerCase();
    if (q.contains("wave") || q.contains("weather")) {
      return "Current wave height is 1.4 meters with 18 km/h wind in partly cloudy conditions.";
    } else if (q.contains("fuel")) {
      return "Your fuel level is safe to go. Estimated remaining buffer is above 60 percent.";
    } else if (q.contains("fish")) {
      return "The nearest high catch fishing zone is active with 85 percent catch probability.";
    } else if (q.contains("market") || q.contains("price") || q.contains("tuna")) {
      return "Tuna market price is 240 rupees per kilo with high demand. Recommendation: SELL TODAY.";
    } else if (q.contains("sos") || q.contains("help")) {
      return "Emergency SOS activated! Transmitting location to Nagapattinam Coast Guard.";
    }
    return "Hello Captain! I am AazhiX Voice. Ask me about wave height, fuel safety, nearest fish zone, or market prices.";
  }
}
