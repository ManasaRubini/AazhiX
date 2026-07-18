import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_constants.dart';

class PlasticService {
  Future<Map<String, dynamic>> detectPlastic(String imagePath) async {
    var request = http.MultipartRequest(
      "POST",
      Uri.parse("${ApiConstants.baseUrl}/plastic"),
    );

    request.files.add(
      await http.MultipartFile.fromPath(
        "file",
        imagePath,
      ),
    );

    var response = await request.send();

    if (response.statusCode == 200) {
      var responseData = await response.stream.bytesToString();
      return jsonDecode(responseData);
    }

    throw Exception("Failed to analyze image");
  }
}