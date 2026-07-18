import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_model.dart';
import 'api_constants.dart';

class MarketService {
  Future<List<MarketModel>> getMarketPrices() async {
    final response = await http.get(
      Uri.parse("${ApiConstants.baseUrl}/market-prices"),
    );

    if (response.statusCode == 200) {
      List data = jsonDecode(response.body);
      return data.map((e) => MarketModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load market prices");
  }
}