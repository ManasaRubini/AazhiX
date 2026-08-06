import 'package:flutter/material.dart';

import '../models/fuel_model.dart';
import '../services/fuel_service.dart';
import '../services/app_language_provider.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  FuelModel? data;
  bool loading = false;

  // Dynamic user inputs (No hardcoded values)
  double fuelCapacity = 60.0;
  double currentFuel = 40.0;
  double distance = 30.0;
  double consumption = 1.2;
  String seaCondition = "medium";

  void optimize() async {
    setState(() => loading = true);

    try {
      final result = await FuelService().optimizeFuel(
        fuelCapacity: fuelCapacity,
        currentFuel: currentFuel,
        consumption: consumption,
        distance: distance,
        seaCondition: seaCondition,
      );

      if (!mounted) return;
      setState(() {
        data = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fuel optimization failed"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Widget infoGlassCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 15),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(color: Colors.white),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _langProvider,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              Container(
                width: double.infinity,
                height: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 8, 39, 93),
                      Color.fromARGB(255, 14, 68, 129),
                      Color.fromARGB(255, 13, 121, 171),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.local_gas_station,
                            color: Colors.orangeAccent,
                            size: 35,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _langProvider.getText("fuel_title"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      /// DYNAMIC INPUT CONTROL PANEL
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.10),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Vessel Trip Parameters",
                              style: TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 15),

                            /// FUEL CAPACITY SLIDER
                            Text(
                              "${_langProvider.getText("fuel_capacity")}: ${fuelCapacity.toStringAsFixed(0)} L",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: fuelCapacity,
                              min: 10,
                              max: 200,
                              divisions: 38,
                              activeColor: Colors.orangeAccent,
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setState(() {
                                  fuelCapacity = val;
                                  if (currentFuel > fuelCapacity) {
                                    currentFuel = fuelCapacity;
                                  }
                                });
                              },
                            ),

                            /// CURRENT FUEL SLIDER
                            Text(
                              "${_langProvider.getText("current_fuel")}: ${currentFuel.toStringAsFixed(0)} L",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: currentFuel,
                              min: 5,
                              max: fuelCapacity,
                              divisions: 39,
                              activeColor: Colors.greenAccent,
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setState(() {
                                  currentFuel = val;
                                });
                              },
                            ),

                            /// DISTANCE SLIDER
                            Text(
                              "${_langProvider.getText("distance")}: ${distance.toStringAsFixed(0)} km",
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Slider(
                              value: distance,
                              min: 5,
                              max: 150,
                              divisions: 29,
                              activeColor: Colors.cyanAccent,
                              inactiveColor: Colors.white24,
                              onChanged: (val) {
                                setState(() {
                                  distance = val;
                                });
                              },
                            ),

                            /// SEA CONDITION TOGGLE
                            Text(
                              _langProvider.getText("sea_condition"),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: ["calm", "medium", "rough"].map((cond) {
                                bool isSel = seaCondition == cond;
                                return ChoiceChip(
                                  label: Text(
                                    cond.toUpperCase(),
                                    style: TextStyle(
                                      color: isSel ? Colors.black : Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  selected: isSel,
                                  selectedColor: Colors.amber,
                                  backgroundColor: Colors.white12,
                                  onSelected: (bool selected) {
                                    if (selected) {
                                      setState(() {
                                        seaCondition = cond;
                                      });
                                    }
                                  },
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 15),

                            SizedBox(
                              width: double.infinity,
                              height: 55,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                onPressed: optimize,
                                icon: const Icon(Icons.auto_graph, color: Colors.white),
                                label: Text(
                                  _langProvider.getText("calculate_fuel"),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      if (loading)
                        const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),

                      if (!loading && data != null) ...[
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.local_gas_station,
                                color: Colors.orange,
                                size: 55,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "${data!.fuelLevel}%",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 40,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _langProvider.getText("current_fuel"),
                                style: const TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        infoGlassCard(
                          _langProvider.getText("consumption"),
                          "${data!.consumption} L/km",
                          Icons.speed,
                          Colors.cyanAccent,
                        ),
                        infoGlassCard(
                          _langProvider.getText("est_cost"),
                          "₹${data!.cost}",
                          Icons.currency_rupee,
                          Colors.greenAccent,
                        ),
                        infoGlassCard(
                          _langProvider.getText("sea_condition"),
                          data!.seaCondition.toUpperCase(),
                          Icons.waves,
                          Colors.blueAccent,
                        ),
                        const SizedBox(height: 15),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(.12),
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.psychology, color: Colors.cyanAccent),
                                  const SizedBox(width: 10),
                                  Text(
                                    _langProvider.getText("recommendation"),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                data!.recommendation,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}