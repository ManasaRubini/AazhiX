import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';

import '../models/weather_model.dart';
import 'api_constants.dart';

class WeatherService {
  Future<WeatherModel> getWeather() async {
    try {
      double? lat;
      double? lon;
      try {
        Position pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.medium,
        ).timeout(const Duration(seconds: 3));
        lat = pos.latitude;
        lon = pos.longitude;
      } catch (_) {}

      String url = ApiConstants.weather;
      if (lat != null && lon != null) {
        url += "?lat=$lat&lon=$lon";
      }

      final response = await http.get(
        Uri.parse(url),
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