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
    try {
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
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return FuelModel.fromJson(jsonDecode(response.body));
      }
    } catch (e) {
      print("FuelService error: $e");
    }

    double factor = seaCondition == "calm" ? 1.0 : (seaCondition == "rough" ? 1.7 : 1.3);
    double adjustedFuel = distance * consumption * factor;
    double remainingFuel = currentFuel - adjustedFuel;
    String status = remainingFuel < 0 ? "NOT SAFE" : (remainingFuel < fuelCapacity * 0.2 ? "RETURN SOON" : "SAFE TO GO");
    String rec = status == "NOT SAFE" ? "Fuel insufficient. Refuel before departure." : (status == "RETURN SOON" ? "Proceed with caution." : "Trip is safe.");

    return FuelModel(
      fuelLevel: double.parse(((currentFuel / fuelCapacity) * 100).toStringAsFixed(2)),
      consumption: consumption,
      cost: double.parse((adjustedFuel * 105).toStringAsFixed(2)),
      seaCondition: seaCondition,
      recommendation: rec,
      status: status,
    );
  }
}