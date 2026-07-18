import 'dart:convert';
import 'package:http/http.dart' as http;

class MarineService {

  static const String baseUrl =
      "http://10.16.236.220:8000";

  Future<Map<String, dynamic>> analyzeAudio(
      String audioPath) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/marine-doctor"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        audioPath,
      ),
    );

    var response = await request.send();

    var body = await response.stream.bytesToString();

    return jsonDecode(body);
  }
}