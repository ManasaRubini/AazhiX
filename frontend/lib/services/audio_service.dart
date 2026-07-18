import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class AudioService {
  Future<Map<String, dynamic>> analyzeAudio(String path) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiConstants.baseUrl}/marine-doctor"),
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