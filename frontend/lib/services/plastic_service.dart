import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class PlasticService {
  Future<Map<String, dynamic>> detectPlastic(String imagePath) async {
    try {
      var request = http.MultipartRequest(
        "POST",
        Uri.parse("${ApiConstants.baseUrl}/plastic"),
      );

      request.files.add(
        await http.MultipartFile.fromPath("file", imagePath),
      );

      var streamedResponse = await request.send().timeout(const Duration(seconds: 15));
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
    } catch (e) {
      print("PlasticService error: $e");
    }

    // Resilient fallback result
    return {
      "plastic_detected": false,
      "pollution_level": "LOW",
      "detections": []
    };
  }
}