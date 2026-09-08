import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../models/fuel_model.dart';
import '../services/fuel_service.dart';
import '../services/fishzone_service.dart';
import '../services/app_language_provider.dart';

class FuelScreen extends StatefulWidget {
  const FuelScreen({super.key});

  @override
  State<FuelScreen> createState() => _FuelScreenState();
}

class _FuelScreenState extends State<FuelScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  final MapController _mapController = MapController();

  FuelModel? data;
  bool loading = false;

  // Dynamic user inputs
  double fuelCapacity = 60.0;
  double currentFuel = 40.0;
  double distance = 30.0;
  double consumption = 1.2;
  String seaCondition = "medium";

  // Selected Route Type
  String selectedRoute = "eco"; // "eco", "direct", "coastal"

  // Real GPS & Simulated Navigation State
  LatLng currentBoatLocation = const LatLng(10.7800, 79.8400);
  LatLng destinationLocation = const LatLng(10.9200, 80.0500);

  bool isNavigating = false;
  int currentWaypointIndex = 0;
  Timer? _navTimer;

  bool isOnLandOrHarbor = true;
  String activePortName = "Nagapattinam Fishing Port";

  // Species & Fish Rich Zone Profit State
  String selectedSpecies = "Tuna";
  int catchProbability = 88;

  final Map<String, double> speciesPrices = {
    "Tuna": 280.0,
    "Mackerel": 220.0,
    "Sardine": 120.0,
    "Pomfret": 450.0,
  };

  final Map<String, double> speciesYieldKg = {
    "Tuna": 85.0,
    "Mackerel": 110.0,
    "Sardine": 180.0,
    "Pomfret": 55.0,
  };

  double get currentPricePerKg => speciesPrices[selectedSpecies] ?? 280.0;
  double get currentYieldKg => speciesYieldKg[selectedSpecies] ?? 85.0;
  double get estimatedRevenue => currentYieldKg * currentPricePerKg;
  double get estimatedFuelCost => (data?.cost != null) ? (data!.cost as num).toDouble() : (distance * consumption * 105);
  double get netTripProfit => estimatedRevenue - estimatedFuelCost;
  double get fuelProfitSavings => (distance * consumption * 0.22 * 105);

  final List<Map<String, dynamic>> ports = [
    {"name": "Nagapattinam Port", "pos": const LatLng(10.7600, 79.8500)},
    {"name": "Chennai Royapuram Port", "pos": const LatLng(13.1200, 80.3000)},
    {"name": "Rameswaram Jetty Port", "pos": const LatLng(9.2800, 79.3100)},
    {"name": "Kanyakumari Harbor", "pos": const LatLng(8.0800, 77.5500)},
    {"name": "Tuticorin Fishing Port", "pos": const LatLng(8.8000, 78.1600)},
  ];

  // Route Coordinates
  List<LatLng> get ecoPoints => [
        currentBoatLocation,
        LatLng(currentBoatLocation.latitude + 0.035, currentBoatLocation.longitude + 0.045),
        LatLng(currentBoatLocation.latitude + 0.070, currentBoatLocation.longitude + 0.110),
        LatLng(currentBoatLocation.latitude + 0.110, currentBoatLocation.longitude + 0.160),
        destinationLocation,
      ];

  List<LatLng> get coastalPoints => [
        currentBoatLocation,
        LatLng(currentBoatLocation.latitude + 0.040, currentBoatLocation.longitude + 0.020),
        LatLng(currentBoatLocation.latitude + 0.090, currentBoatLocation.longitude + 0.070),
        LatLng(currentBoatLocation.latitude + 0.120, currentBoatLocation.longitude + 0.140),
        destinationLocation,
      ];

  List<LatLng> get directPoints => [
        currentBoatLocation,
        destinationLocation,
      ];

  List<LatLng> get activeRoutePoints {
    if (selectedRoute == "eco") return ecoPoints;
    if (selectedRoute == "coastal") return coastalPoints;
    return directPoints;
  }

  @override
  void initState() {
    super.initState();
    _fetchLocation();
    _fetchPFZDestination();
    optimize();
  }

  @override
  void dispose() {
    _navTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 4));
      if (!mounted) return;

      LatLng userPos = LatLng(position.latitude, position.longitude);
      bool offshore = (userPos.longitude > 80.05 || userPos.latitude < 7.9);

      if (offshore) {
        setState(() {
          isOnLandOrHarbor = false;
          activePortName = "Live Offshore GPS";
          currentBoatLocation = userPos;
        });
      } else {
        double minDistance = double.infinity;
        Map<String, dynamic> nearestPort = ports.first;

        for (var port in ports) {
          LatLng pPos = port["pos"];
          double dist = Distance().as(LengthUnit.Kilometer, userPos, pPos);
          if (dist < minDistance) {
            minDistance = dist;
            nearestPort = port;
          }
        }

        setState(() {
          isOnLandOrHarbor = true;
          activePortName = nearestPort["name"];
          currentBoatLocation = nearestPort["pos"];
        });
      }
      await _fetchPFZDestination();
      _mapController.move(currentBoatLocation, 11.5);
    } catch (e) {
      debugPrint("Location lookup fallback used: $e");
    }
  }

  Future<void> _fetchPFZDestination() async {
    try {
      final pfzData = await FishzoneService().getFishZone(
        currentBoatLocation.latitude,
        currentBoatLocation.longitude,
        selectedSpecies,
      );

      if (!mounted) return;
      setState(() {
        catchProbability = pfzData["fish_probability"] ?? 88;
        if (pfzData["latitude"] != null && pfzData["longitude"] != null) {
          destinationLocation = LatLng(
            (pfzData["latitude"] as num).toDouble(),
            (pfzData["longitude"] as num).toDouble(),
          );
        }
      });
    } catch (e) {
      debugPrint("PFZ destination lookup note: $e");
    }
  }

  void startNavigationSimulation() {
    if (isNavigating) {
      _navTimer?.cancel();
      setState(() {
        isNavigating = false;
        currentWaypointIndex = 0;
      });
      return;
    }

    setState(() {
      isNavigating = true;
      currentWaypointIndex = 0;
    });

    List<LatLng> points = activeRoutePoints;

    _navTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (currentWaypointIndex < points.length - 1) {
        setState(() {
          currentWaypointIndex++;
          currentBoatLocation = points[currentWaypointIndex];
        });
        _mapController.move(currentBoatLocation, 12.5);
      } else {
        timer.cancel();
        setState(() {
          isNavigating = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(" 🐟 Arrived at High-Yield $selectedSpecies PFZ! Net Profit Boost: +₹${fuelProfitSavings.toStringAsFixed(0)}"),
            backgroundColor: Colors.green,
          ),
        );
      }
    });
  }

  void optimize() async {
    setState(() => loading = true);

    try {
      double routeFactor = selectedRoute == "eco" ? 0.85 : (selectedRoute == "direct" ? 1.15 : 1.0);
      double effectiveDistance = distance * routeFactor;

      final result = await FuelService().optimizeFuel(
        fuelCapacity: fuelCapacity,
        currentFuel: currentFuel,
        consumption: consumption,
        distance: effectiveDistance,
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
    }
  }

  String getTurnGuidanceText() {
    String prefix = isOnLandOrHarbor ? "Departure from $activePortName: " : "";
    if (selectedRoute == "eco") {
      if (currentWaypointIndex == 0) return "${prefix}Routing to $catchProbability% High-Profit $selectedSpecies Zone via Eco Current vector (+1.8 kt drift)";
      if (currentWaypointIndex == 1) return "Turn 15° Right into Deep Ocean Current Channel (saving 4.2 L fuel)";
      if (currentWaypointIndex == 2) return "Maintain 8.5 kt speed to maximize net trip profit to ₹${netTripProfit.toStringAsFixed(0)}";
      return "Approaching High Density $selectedSpecies Hotspot ($catchProbability% catch prob)";
    } else if (selectedRoute == "coastal") {
      return "${prefix}Coastline Safety Route: Stay within 4 NM from shore to reach $selectedSpecies PFZ";
    } else {
      return "${prefix}Direct Route: Straight path to $selectedSpecies PFZ with higher wave drag (+15% fuel)";
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

  Widget routeOptionCard({
    required String id,
    required String title,
    required String subtitle,
    required String fuelDelta,
    required IconData icon,
    required Color color,
  }) {
    bool isSelected = selectedRoute == id;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedRoute = id;
          currentWaypointIndex = 0;
        });
        optimize();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(.20) : Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : Colors.white24,
            width: isSelected ? 2.5 : 1.0,
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.2),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: color.withOpacity(.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fuelDelta,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double fuelSavedLiters = (distance * consumption * 0.22);
    double costSavedRupees = fuelSavedLiters * 105;

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
                            Icons.map_rounded,
                            color: Colors.cyanAccent,
                            size: 32,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _langProvider.getText("fuel_title"),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isOnLandOrHarbor ? Colors.amberAccent.withOpacity(.2) : Colors.greenAccent.withOpacity(.2),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: isOnLandOrHarbor ? Colors.amberAccent : Colors.greenAccent),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isOnLandOrHarbor ? Icons.anchor : Icons.gps_fixed,
                                  color: isOnLandOrHarbor ? Colors.amberAccent : Colors.greenAccent,
                                  size: 14,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isOnLandOrHarbor ? "PORT ORIGIN MODE" : "GPS OFFSHORE",
                                  style: TextStyle(
                                    color: isOnLandOrHarbor ? Colors.amberAccent : Colors.greenAccent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 18),

                      /// 🐟 TARGET SPECIES & PROFIT OPTIMIZER SELECTOR CHIPS
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.10),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.stars, color: Colors.amberAccent, size: 20),
                                SizedBox(width: 8),
                                Text(
                                  "Target High-Profit Fish Species",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: speciesPrices.keys.map((species) {
                                  bool isSel = selectedSpecies == species;
                                  double price = speciesPrices[species]!;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: ChoiceChip(
                                      avatar: Icon(
                                        Icons.set_meal,
                                        color: isSel ? Colors.black : Colors.amberAccent,
                                        size: 18,
                                      ),
                                      label: Text(
                                        "$species (₹${price.toStringAsFixed(0)}/kg)",
                                        style: TextStyle(
                                          color: isSel ? Colors.black : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      selected: isSel,
                                      selectedColor: Colors.amberAccent,
                                      backgroundColor: Colors.white12,
                                      onSelected: (bool selected) {
                                        if (selected) {
                                          setState(() {
                                            selectedSpecies = species;
                                          });
                                          _fetchPFZDestination();
                                          optimize();
                                        }
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      /// 🗺️ REAL INTERACTIVE MARITIME GPS NAVIGATION MAP CARD
                      Container(
                        height: 390,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(.5), width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.4),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: currentBoatLocation,
                                initialZoom: 11.5,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                                ),
                                PolylineLayer(
                                  polylines: [
                                    // Direct Route (Red Line)
                                    Polyline(
                                      points: directPoints,
                                      color: selectedRoute == "direct" ? Colors.redAccent : Colors.redAccent.withOpacity(.3),
                                      strokeWidth: selectedRoute == "direct" ? 5.0 : 2.5,
                                    ),
                                    // Coastal Route (Amber Line)
                                    Polyline(
                                      points: coastalPoints,
                                      color: selectedRoute == "coastal" ? Colors.amberAccent : Colors.amberAccent.withOpacity(.3),
                                      strokeWidth: selectedRoute == "coastal" ? 5.0 : 2.5,
                                    ),
                                    // AI Eco Route (Green Line)
                                    Polyline(
                                      points: ecoPoints,
                                      color: selectedRoute == "eco" ? Colors.greenAccent : Colors.greenAccent.withOpacity(.3),
                                      strokeWidth: selectedRoute == "eco" ? 5.5 : 3.0,
                                    ),
                                  ],
                                ),
                                MarkerLayer(
                                  markers: [
                                    // Boat Location Marker
                                    Marker(
                                      point: currentBoatLocation,
                                      width: 60,
                                      height: 60,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              color: Colors.blue.shade900.withOpacity(.85),
                                              shape: BoxShape.circle,
                                              border: Border.all(color: Colors.cyanAccent, width: 2),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.cyanAccent.withOpacity(.6),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.directions_boat,
                                              color: Colors.cyanAccent,
                                              size: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Ocean Current Vector Waypoints
                                    if (selectedRoute == "eco")
                                      Marker(
                                        point: ecoPoints[1],
                                        width: 40,
                                        height: 40,
                                        child: const Icon(
                                          Icons.navigation_rounded,
                                          color: Colors.greenAccent,
                                          size: 26,
                                        ),
                                      ),
                                    // Target Fish-Rich Zone Destination Marker
                                    Marker(
                                      point: destinationLocation,
                                      width: 140,
                                      height: 75,
                                      child: Column(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Colors.green.shade900.withOpacity(.9),
                                              borderRadius: BorderRadius.circular(16),
                                              border: Border.all(color: Colors.amberAccent, width: 2),
                                              boxShadow: const [
                                                BoxShadow(color: Colors.black45, blurRadius: 8),
                                              ],
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Icon(Icons.set_meal, color: Colors.amberAccent, size: 20),
                                                const SizedBox(width: 6),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      "$catchProbability% $selectedSpecies",
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                    const Text(
                                                      "HIGH-PROFIT PFZ",
                                                      style: TextStyle(
                                                        color: Colors.amberAccent,
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 9,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            /// TURN-BY-TURN NAVIGATION HUD BANNER (LIKE MAPS NAV)
                            Positioned(
                              top: 12,
                              left: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(.82),
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: Colors.cyanAccent.withOpacity(.6)),
                                  boxShadow: const [
                                    BoxShadow(color: Colors.black45, blurRadius: 10),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.cyanAccent.withOpacity(.2),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(Icons.turn_right_rounded, color: Colors.cyanAccent, size: 24),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            getTurnGuidanceText(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w600,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            "Target: $selectedSpecies ($catchProbability%) | Net Profit: ₹${netTripProfit.toStringAsFixed(0)}",
                                            style: const TextStyle(color: Colors.cyanAccent, fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            /// MAP NAVIGATION ACTION BUTTONS
                            Positioned(
                              bottom: 12,
                              right: 12,
                              child: Column(
                                children: [
                                  FloatingActionButton.small(
                                    heroTag: "recenter",
                                    backgroundColor: Colors.black87,
                                    onPressed: () {
                                      _mapController.move(currentBoatLocation, 12);
                                    },
                                    child: const Icon(Icons.my_location, color: Colors.cyanAccent),
                                  ),
                                  const SizedBox(height: 8),
                                  FloatingActionButton.extended(
                                    heroTag: "start_nav",
                                    backgroundColor: isNavigating ? Colors.redAccent : Colors.greenAccent,
                                    onPressed: startNavigationSimulation,
                                    icon: Icon(
                                      isNavigating ? Icons.stop : Icons.play_arrow,
                                      color: isNavigating ? Colors.white : Colors.black,
                                    ),
                                    label: Text(
                                      isNavigating ? "STOP NAV" : "START NAV",
                                      style: TextStyle(
                                        color: isNavigating ? Colors.white : Colors.black,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// 💰 NET VOYAGE PROFIT METRICS DASHBOARD (PFZ PROFIT OPTIMIZATION)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.amber.shade900.withOpacity(.6),
                              Colors.teal.shade900.withOpacity(.6),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.amberAccent, width: 1.5),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.amberAccent.withOpacity(.2),
                              blurRadius: 12,
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.monetization_on, color: Colors.amberAccent, size: 28),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Net Voyage Profit Predictor",
                                        style: TextStyle(
                                          color: Colors.amberAccent,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        "AI Optimized Route to High-Density $selectedSpecies Zone",
                                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text("Est. Catch Revenue", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "₹${estimatedRevenue.toStringAsFixed(0)}",
                                      style: const TextStyle(color: Colors.greenAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text("${currentYieldKg.toStringAsFixed(0)} kg @ ₹${currentPricePerKg.toStringAsFixed(0)}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                  ],
                                ),
                                Container(height: 45, width: 1, color: Colors.white24),
                                Column(
                                  children: [
                                    const Text("Optimized Fuel Cost", style: TextStyle(color: Colors.white70, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    Text(
                                      "-₹${estimatedFuelCost.toStringAsFixed(0)}",
                                      style: const TextStyle(color: Colors.orangeAccent, fontSize: 20, fontWeight: FontWeight.bold),
                                    ),
                                    Text("Saved ₹${costSavedRupees.toStringAsFixed(0)} in fuel", style: const TextStyle(color: Colors.greenAccent, fontSize: 11)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.black45,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.amberAccent.withOpacity(.4)),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Row(
                                    children: [
                                      Icon(Icons.trending_up, color: Colors.greenAccent),
                                      SizedBox(width: 8),
                                      Text(
                                        "NET TRIP PROFIT:",
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "₹${netTripProfit.toStringAsFixed(0)}",
                                    style: const TextStyle(
                                      color: Colors.amberAccent,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      /// BEST FUEL-OPTIMIZED ROUTE SELECTION PANEL
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.10),
                          borderRadius: BorderRadius.circular(25),
                          border: Border.all(color: Colors.cyanAccent.withOpacity(.4)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.navigation, color: Colors.cyanAccent, size: 24),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    _langProvider.getText("route_opt_title"),
                                    style: const TextStyle(
                                      color: Colors.cyanAccent,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 15),

                            routeOptionCard(
                              id: "eco",
                              title: _langProvider.getText("eco_route"),
                              subtitle: "Follows ocean currents • Reduces wave drag",
                              fuelDelta: "-22% Fuel",
                              icon: Icons.eco,
                              color: Colors.greenAccent,
                            ),
                            routeOptionCard(
                              id: "coastal",
                              title: _langProvider.getText("coastal_route"),
                              subtitle: "Stays near coastal ports • Moderate burn",
                              fuelDelta: "Standard",
                              icon: Icons.shield,
                              color: Colors.amberAccent,
                            ),
                            routeOptionCard(
                              id: "direct",
                              title: _langProvider.getText("direct_route"),
                              subtitle: "High wave resistance • Fast straight path",
                              fuelDelta: "+15% Fuel",
                              icon: Icons.speed,
                              color: Colors.redAccent,
                            ),
                          ],
                        ),
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
                                  _langProvider.getText("calc_fuel"),
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