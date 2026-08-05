class MarketModel {
  final String fish;
  final double price;
  final String demand;
  final String recommendation;

  MarketModel({
    required this.fish,
    required this.price,
    required this.demand,
    required this.recommendation,
  });

  factory MarketModel.fromJson(Map<String, dynamic> json) {
    return MarketModel(
      fish: json["fish"]?.toString() ?? "Fish",
      price: (json["price"] as num?)?.toDouble() ?? 150.0,
      demand: json["demand"]?.toString() ?? "medium",
      recommendation: json["recommendation"]?.toString() ?? "WAIT 1 DAY",
    );
  }
}