class FuelModel {
  final double fuelLevel;
  final double consumption;
  final double cost;
  final String seaCondition;
  final String recommendation;
  final String status; // ADD THIS

  FuelModel({
    required this.fuelLevel,
    required this.consumption,
    required this.cost,
    required this.seaCondition,
    required this.recommendation,
    required this.status,
  });

  factory FuelModel.fromJson(Map<String, dynamic> json) {
    return FuelModel(
      fuelLevel: (json["fuel_level"] ?? 0).toDouble(),
      consumption: (json["consumption"] ?? 0).toDouble(),
      cost: (json["cost"] ?? 0).toDouble(),
      seaCondition: json["sea_condition"] ?? "",
      recommendation: json["recommendation"] ?? "",
      status: json["status"] ?? "",
    );
  }
}