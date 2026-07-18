import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/market_model.dart';

class MarketService {
  static const String baseUrl = "http://10.16.236.220:8000";

  Future<List<MarketModel>> getMarketPrices() async {

    final response =
        await http.get(Uri.parse("$baseUrl/market-prices"));

    if (response.statusCode == 200) {

      List data = jsonDecode(response.body);

      return data.map((e) => MarketModel.fromJson(e)).toList();
    }

    throw Exception("Failed to load market prices");
  }
}