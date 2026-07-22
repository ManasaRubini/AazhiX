import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import 'api_constants.dart';

class WeatherService {
  Future<WeatherModel> getWeather() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/weather"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return WeatherModel.fromJson(
          jsonDecode(response.body),
        );
      }
    } catch (e) {
      print("WeatherService error: $e");
    }

    return WeatherModel(
      temperature: 29.0,
      humidity: 78.0,
      windSpeed: 18.0,
      waveHeight: 1.4,
      condition: "Partly Cloudy",
    );
  }
}