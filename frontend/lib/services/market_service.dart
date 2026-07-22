import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_model.dart';
import 'api_constants.dart';

class MarketService {
  Future<List<MarketModel>> getMarketPrices() async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/market-prices"),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        List data = jsonDecode(response.body);
        return data.map((e) => MarketModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("MarketService error: $e");
    }

    return [
      MarketModel(fish: "Tuna", price: 235.0, demand: "high", recommendation: "SELL TODAY"),
      MarketModel(fish: "Sardine", price: 105.0, demand: "medium", recommendation: "WAIT 1 DAY"),
      MarketModel(fish: "Mackerel", price: 145.0, demand: "medium", recommendation: "WAIT 1 DAY"),
      MarketModel(fish: "Pomfret", price: 320.0, demand: "high", recommendation: "SELL TODAY"),
      MarketModel(fish: "Anchovy", price: 85.0, demand: "low", recommendation: "DO NOT SELL"),
      MarketModel(fish: "Salmon", price: 460.0, demand: "high", recommendation: "SELL TODAY"),
    ];
  }
}