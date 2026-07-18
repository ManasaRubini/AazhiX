import 'dart:convert';
import 'package:http/http.dart' as http;

class AudioService {

  static const String baseUrl = "http://10.16.268.220:8000";

  Future<Map<String, dynamic>> analyzeAudio(String path) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/engine-analysis"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        path,
      ),
    );

    var response = await request.send();

    var body = await response.stream.bytesToString();

    return jsonDecode(body);
  }
}