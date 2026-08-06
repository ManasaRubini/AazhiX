import 'package:flutter/material.dart';

import '../models/market_model.dart';
import '../services/market_service.dart';
import '../services/app_language_provider.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  late Future<List<MarketModel>> marketData;

  @override
  void initState() {
    super.initState();
    marketData = MarketService().getMarketPrices();
  }

  Color getDemandColor(String demand) {
    switch (demand.toLowerCase()) {
      case "high":
        return Colors.green;
      case "medium":
        return Colors.orange;
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _langProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: const Color(0xff041B43),
          body: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/sea_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(.55),
                ),
              ),
              SafeArea(
                child: FutureBuilder<List<MarketModel>>(
                  future: marketData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: Colors.cyanAccent),
                      );
                    }

                    if (snapshot.hasError) {
                      return const Center(
                        child: Text(
                          "Unable to fetch market prices",
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }

                    final fishes = snapshot.data!;

                    return Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER (WRAPPED IN EXPANDED TO ELIMINATE YELLOW OVERFLOW BANNER)
                          Row(
                            children: [
                              const Icon(
                                Icons.auto_graph,
                                color: Colors.cyanAccent,
                                size: 32,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _langProvider.getText("market_intel"),
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// AI CARD
                          Container(
                            padding: const EdgeInsets.all(18),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(.08),
                              borderRadius: BorderRadius.circular(25),
                              border: Border.all(color: Colors.white24),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.psychology,
                                  color: Colors.cyanAccent,
                                  size: 38,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        _langProvider.getText("recommendation"),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 17,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        fishes.isNotEmpty
                                            ? "${_langProvider.getText("top_catch")}: ${_langProvider.translateFish(fishes[0].fish)}\n${_langProvider.translateTrade(fishes[0].recommendation)}"
                                            : "Loading...",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          height: 1.5,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          /// MARKET LIST WITH FISH NAME & TRADE TRANSLATION
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: () async {
                                setState(() {
                                  marketData = MarketService().getMarketPrices();
                                });
                              },
                              child: ListView.builder(
                                itemCount: fishes.length,
                                itemBuilder: (context, index) {
                                  final fish = fishes[index];
                                  final translatedFishName = _langProvider.translateFish(fish.fish);
                                  final translatedTrade = _langProvider.translateTrade(fish.recommendation);

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 14),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.08),
                                      borderRadius: BorderRadius.circular(22),
                                      border: Border.all(color: Colors.white24),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 54,
                                          height: 54,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.cyan.withOpacity(.2),
                                          ),
                                          child: const Icon(
                                            Icons.set_meal,
                                            color: Colors.cyanAccent,
                                            size: 28,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                translatedFishName,
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 17,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "₹${fish.price}/kg",
                                                style: const TextStyle(color: Colors.white70),
                                              ),
                                              const SizedBox(height: 6),
                                              Text(
                                                translatedTrade,
                                                style: TextStyle(
                                                  color: fish.recommendation.contains("SELL")
                                                      ? Colors.greenAccent
                                                      : fish.recommendation.contains("WAIT")
                                                          ? Colors.orangeAccent
                                                          : Colors.redAccent,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 12,
                                            vertical: 6,
                                          ),
                                          decoration: BoxDecoration(
                                            color: getDemandColor(fish.demand),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                          child: Text(
                                            fish.demand.toUpperCase() == "HIGH"
                                                ? _langProvider.getText("high_demand")
                                                : fish.demand.toUpperCase() == "MEDIUM"
                                                    ? _langProvider.getText("medium_demand")
                                                    : _langProvider.getText("low_demand"),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}