import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';
import 'api_constants.dart';

class WeatherService {

  Future<WeatherModel> getWeather() async {

    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/weather"),
    );

    if (response.statusCode == 200) {

      return WeatherModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception("Failed to load weather");
  }
}