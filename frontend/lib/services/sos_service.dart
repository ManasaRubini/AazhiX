import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class SosService {
  Future<Map<String, dynamic>> triggerSOS(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.baseUrl}/api/sos/"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "latitude": latitude,
          "longitude": longitude,
          "trigger": "manual"
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {
          "status": "ERROR",
          "message": "Server error: ${response.statusCode}"
        };
      }
    } catch (e) {
      return {
        "status": "ERROR",
        "message": e.toString()
      };
    }
  }
}