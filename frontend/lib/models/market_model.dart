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
      fish: json["fish"],
      price: (json["price"] as num).toDouble(),
      demand: json["demand"],
      recommendation: json["recommendation"],
    );
  }
}