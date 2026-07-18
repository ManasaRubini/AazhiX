class PlasticModel {
  final String riskLevel;
  final double density;
  final double latitude;
  final double longitude;
  final String recommendation;

  PlasticModel({
    required this.riskLevel,
    required this.density,
    required this.latitude,
    required this.longitude,
    required this.recommendation,
  });

  factory PlasticModel.fromJson(Map<String, dynamic> json) {
    return PlasticModel(
      riskLevel: json["risk_level"],
      density: json["density"].toDouble(),
      latitude: json["latitude"].toDouble(),
      longitude: json["longitude"].toDouble(),
      recommendation: json["recommendation"],
    );
  }
}