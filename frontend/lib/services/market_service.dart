import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/market_model.dart';
import 'api_constants.dart';

class MarketService {
  static const String _cacheKey = "cached_market_prices";

  Future<List<MarketModel>> getMarketPrices() async {
    // 1. Try Network Request
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.baseUrl}/market-prices"),
      ).timeout(const Duration(seconds: 4));

      if (response.statusCode == 200) {
        final body = response.body;
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, body);
        List data = jsonDecode(body);
        return data.map((e) => MarketModel.fromJson(e)).toList();
      }
    } catch (e) {
      print("MarketService network note: $e");
    }

    // 2. Try Cached Market Prices
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? cachedJson = prefs.getString(_cacheKey);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        List data = jsonDecode(cachedJson);
        return data.map((e) => MarketModel.fromJson(e)).toList();
      }
    } catch (_) {}

    // 3. Complete Offline Local Market Dataset
    return [
      MarketModel(fish: "Tuna", price: 242.4, demand: "medium", recommendation: "WAIT 1 DAY"),
      MarketModel(fish: "Sardine", price: 125.4, demand: "high", recommendation: "SELL TODAY"),
      MarketModel(fish: "Mackerel", price: 165.0, demand: "high", recommendation: "SELL TODAY"),
      MarketModel(fish: "Pomfret", price: 339.2, demand: "medium", recommendation: "WAIT 1 DAY"),
      MarketModel(fish: "Anchovy", price: 91.8, demand: "medium", recommendation: "WAIT 1 DAY"),
      MarketModel(fish: "Salmon", price: 480.0, demand: "high", recommendation: "SELL TODAY"),
    ];
  }
}