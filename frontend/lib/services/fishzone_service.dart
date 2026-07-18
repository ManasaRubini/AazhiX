import 'dart:convert';
import 'package:http/http.dart' as http;

class FishzoneService {

  static const String baseUrl =
      "http://10.16.236.220:8000";

  Future<Map<String, dynamic>> getFishZone(
      double lat,
      double lon,
      String species,
      ) async {

    final url = Uri.parse(
      "$baseUrl/api/fishzone/?lat=$lat&lon=$lon&species=$species",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    }

    throw Exception("Failed to fetch fish zone");
  }
}