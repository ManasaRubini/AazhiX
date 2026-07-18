import 'dart:convert';
import 'package:http/http.dart' as http;


class PlasticService {
  static const baseUrl = "http://10.16.236.220:8000";

  Future<Map<String, dynamic>> detectPlastic(
      String imagePath) async {

    var request = http.MultipartRequest(
      "POST",
      Uri.parse("$baseUrl/plastic"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imagePath,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData =
          await response.stream.bytesToString();

      return jsonDecode(responseData);
    }

    throw Exception("Failed to analyze image");
  }
}