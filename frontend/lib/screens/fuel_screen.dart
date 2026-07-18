import 'package:flutter/material.dart';

import '../models/fuel_model.dart';
import '../services/fuel_service.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {

  FuelModel? data;
  bool loading = false;

  void optimize() async {
    setState(() => loading = true);

    try {
      final result = await FuelService().optimizeFuel(
        fuelCapacity: 30,
        currentFuel: 20,
        consumption: 1.2,
        distance: 20,
        seaCondition: "medium",
      );

      setState(() {
        data = result;
        loading = false;
      });

    } catch (e) {
      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Fuel optimization failed"),
        ),
      );
    }
  }

  Widget infoCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xff122645),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [

          CircleAvatar(
            backgroundColor: color.withOpacity(.2),
            child: Icon(icon, color: color),
          ),

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
            ),
          )
        ],
      ),
    );
  }
  Widget infoGlassCard(
  String title,
  String value,
  IconData icon,
  Color color,
) {
  return Container(
    margin: const EdgeInsets.only(
      bottom: 15,
    ),

    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.12),

      borderRadius:
          BorderRadius.circular(25),

      border: Border.all(
        color: Colors.white24,
      ),
    ),

    child: Row(
      children: [

        Icon(
          icon,
          color: color,
          size: 32,
        ),

        const SizedBox(width: 15),

        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              color: Colors.white,
            ),
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
  return Scaffold(
    backgroundColor: Colors.transparent,

    body: Stack(
      children: [

        /// FULL SCREEN GRADIENT
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

        /// CONTENT
        SafeArea(
          child: loading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                )

              : data == null

                  /// INITIAL SCREEN
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [

                            Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const RadialGradient(
                                  colors: [
                                    Colors.orangeAccent,
                                    Colors.deepOrange,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color:
                                        Colors.orange.withOpacity(.5),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.local_gas_station,
                                color: Colors.white,
                                size: 90,
                              ),
                            ),

                            const SizedBox(height: 30),

                            const Text(
                              "Smart Fuel Optimization",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 15),

                            const Text(
                              "AI analyzes sea conditions and fuel consumption to recommend the safest route.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),

                            const SizedBox(height: 40),

                            SizedBox(
                              width: double.infinity,
                              height: 60,
                              child: ElevatedButton.icon(
                                style:
                                    ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.orange,
                                  shape:
                                      RoundedRectangleBorder(
                                    borderRadius:
                                        BorderRadius.circular(
                                            20),
                                  ),
                                ),
                                onPressed: optimize,
                                icon: const Icon(
                                  Icons.auto_graph,
                                  color: Colors.white,
                                ),
                                label: const Text(
                                  "Start Optimization",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )

                  /// RESULT SCREEN
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [

                          const Row(
                            children: [
                              Icon(
                                Icons.local_gas_station,
                                color: Colors.orangeAccent,
                                size: 35,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Fuel Optimizer",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 30,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 25),

                          Container(
                            padding:
                                const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.12),
                              borderRadius:
                                  BorderRadius.circular(
                                      25),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),
                            child: Column(
                              children: [

                                const Icon(
                                  Icons.local_gas_station,
                                  color: Colors.orange,
                                  size: 60,
                                ),

                                const SizedBox(height: 10),

                                Text(
                                  "${data!.fuelLevel}%",
                                  style:
                                      const TextStyle(
                                    color: Colors.white,
                                    fontSize: 40,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),

                                const Text(
                                  "Fuel Remaining",
                                  style: TextStyle(
                                    color:
                                        Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          infoGlassCard(
                            "Consumption",
                            "${data!.consumption} L/hr",
                            Icons.speed,
                            Colors.cyanAccent,
                          ),

                          infoGlassCard(
                            "Estimated Cost",
                            "₹${data!.cost}",
                            Icons.currency_rupee,
                            Colors.greenAccent,
                          ),

                          infoGlassCard(
                            "Sea Condition",
                            data!.seaCondition,
                            Icons.waves,
                            Colors.blueAccent,
                          ),

                          const SizedBox(height: 15),

                          SizedBox(
                            width: double.infinity,
                            height: 60,
                            child: ElevatedButton.icon(
                              style:
                                  ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.orange,
                                shape:
                                    RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius
                                          .circular(20),
                                ),
                              ),
                              onPressed: optimize,
                              icon: const Icon(
                                Icons.refresh,
                                color: Colors.white,
                              ),
                              label: const Text(
                                "Re-Optimize",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          Container(
                            width: double.infinity,
                            padding:
                                const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white
                                  .withOpacity(.12),
                              borderRadius:
                                  BorderRadius.circular(
                                      25),
                              border: Border.all(
                                color: Colors.white24,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [

                                const Row(
                                  children: [
                                    Icon(
                                      Icons.psychology,
                                      color: Colors
                                          .cyanAccent,
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "AI Recommendation",
                                      style:
                                          TextStyle(
                                        color: Colors
                                            .white,
                                        fontSize: 18,
                                        fontWeight:
                                            FontWeight
                                                .bold,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 15),

                                Text(
                                  data!.recommendation,
                                  style:
                                      const TextStyle(
                                    color:
                                        Colors.white70,
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
        ),
      ],
    ),
  );
}
}