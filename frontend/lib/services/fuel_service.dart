import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/fuel_model.dart';
import 'api_constants.dart';

class FuelService {

  Future<FuelModel> optimizeFuel({
  required double fuelCapacity,
  required double currentFuel,
  required double consumption,
  required double distance,
  required String seaCondition,
  }) async {

    final response = await http.post(
      Uri.parse("${ApiConstants.baseUrl}/fuel/optimize"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "fuel_capacity": fuelCapacity,
        "current_fuel": currentFuel,
        "distance_km": distance,
        "consumption_per_km": consumption,
        "sea_condition": seaCondition,
      }),
    );

    if (response.statusCode == 200) {
      return FuelModel.fromJson(jsonDecode(response.body));
    }

    throw Exception("Fuel optimization failed");
  }
}