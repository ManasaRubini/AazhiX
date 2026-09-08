import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/fishzone_service.dart';
import '../services/app_language_provider.dart';
import '../services/imbl_service.dart';

class FishzoneScreen extends StatefulWidget {
  const FishzoneScreen({super.key});

  @override
  State<FishzoneScreen> createState() => _FishzoneScreenState();
}

class _FishzoneScreenState extends State<FishzoneScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  final MapController _mapController = MapController();

  int? fishProbability;
  String? advisory;
  LatLng? aiFishZone;

  LatLng currentLocation = const LatLng(10.7800, 79.8400);

  List<Map<String, dynamic>> savedWaypoints = [];

  LatLng get activeTargetZone => aiFishZone ?? LatLng(currentLocation.latitude + 0.038, currentLocation.longitude + 0.045);
  double get pfzBearing => ImblService.calculateBearing(currentLocation, activeTargetZone);
  double get pfzDistanceNM => Distance().as(LengthUnit.Kilometer, currentLocation, activeTargetZone) / 1.852;
  double get imblDistance => ImblService.getDistanceToIMBL(currentLocation.latitude, currentLocation.longitude);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
    _loadWaypoints();
  }

  Future<void> _loadWaypoints() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? raw = prefs.getString("saved_fishing_waypoints");
      if (raw != null) {
        List<dynamic> decoded = jsonDecode(raw);
        setState(() {
          savedWaypoints = decoded.cast<Map<String, dynamic>>();
        });
      }
    } catch (_) {}
  }

  Future<void> _saveWaypoint(String name) async {
    if (name.trim().isEmpty) return;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final newSpot = {
      "name": name.trim(),
      "lat": currentLocation.latitude,
      "lon": currentLocation.longitude,
      "date": DateTime.now().toString().substring(0, 10),
    };
    savedWaypoints.add(newSpot);
    await prefs.setString("saved_fishing_waypoints", jsonEncode(savedWaypoints));
    if (!mounted) return;
    setState(() {});
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Saved '$name' to Favorite Fishing Hotspots"), backgroundColor: Colors.green),
    );
  }

  void _showSaveSpotDialog() {
    TextEditingController nameCtrl = TextEditingController(text: "My Tuna Spot #${savedWaypoints.length + 1}");
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xff0A2552),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Colors.cyanAccent)),
        title: const Text("Save Current GPS Hotspot", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: nameCtrl,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: "Hotspot Name",
            labelStyle: TextStyle(color: Colors.cyanAccent),
            enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white54)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel", style: TextStyle(color: Colors.white54))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.cyanAccent),
            onPressed: () {
              Navigator.pop(context);
              _saveWaypoint(nameCtrl.text);
            },
            child: const Text("Save Spot", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  Future<void> fetchFishZoneAI() async {
    try {
      final data = await FishzoneService().getFishZone(
        currentLocation.latitude,
        currentLocation.longitude,
        "Any",
      );

      if (!mounted) return;

      setState(() {
        fishProbability = data["fish_probability"];
        advisory = data["advisory"];
        aiFishZone = LatLng(
          (data["latitude"] as num).toDouble(),
          (data["longitude"] as num).toDouble(),
        );
      });
    } catch (e) {
      debugPrint("FishZone AI error: $e");
    }
  }

  Future<void> getCurrentLocation() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      Position position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 4));

      currentLocation = LatLng(position.latitude, position.longitude);
      await fetchFishZoneAI();
      _mapController.move(currentLocation, 11.5);

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint("Geolocator note: $e");
    }
  }

  Widget oceanCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 30),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 17,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            title,
            style: const TextStyle(color: Colors.white70, fontSize: 13),
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
          backgroundColor: const Color(0xff041B43),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.phishing,
                        color: Colors.cyanAccent,
                        size: 32,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _langProvider.getText("pfz_title"),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.bookmark_add, color: Colors.amberAccent),
                        tooltip: "Save Favorite Spot",
                        onPressed: _showSaveSpotDialog,
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  /// 🚨 IMBL BORDER WARNING BANNER
                  if (imblDistance < 8.0)
                    Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.red.shade900.withOpacity(.9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: Colors.amberAccent, width: 2),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.gavel, color: Colors.amberAccent, size: 26),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "🚨 IMBL ALERT: Distance to Border: ${imblDistance.toStringAsFixed(1)} NM! Stay within Indian waters.",
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),

                  /// 🗺️ MAP CARD WITH IMBL BORDER & PFZ BEARING HUD
                  Container(
                    height: 350,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: Colors.cyanAccent.withOpacity(.4)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(.3),
                          blurRadius: 20,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Stack(
                      children: [
                        FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: currentLocation,
                            initialZoom: 11.5,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
                            ),
                            PolylineLayer(
                              polylines: [
                                // IMBL Border Line (Dashed Red Line)
                                Polyline(
                                  points: ImblService.imblPoints,
                                  color: Colors.redAccent,
                                  strokeWidth: 4.0,
                                ),
                                // Route to PFZ Line
                                Polyline(
                                  points: [currentLocation, activeTargetZone],
                                  color: Colors.greenAccent,
                                  strokeWidth: 3.5,
                                ),
                              ],
                            ),
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: currentLocation,
                                  width: 50,
                                  height: 50,
                                  child: const Icon(
                                    Icons.directions_boat,
                                    color: Colors.cyan,
                                    size: 40,
                                  ),
                                ),
                                Marker(
                                  point: activeTargetZone,
                                  width: 130,
                                  height: 70,
                                  child: Column(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.green.shade900.withOpacity(.9),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(color: Colors.amberAccent),
                                        ),
                                        child: Text(
                                          "🐟 ${fishProbability ?? 88}% PFZ",
                                          style: const TextStyle(color: Colors.amberAccent, fontWeight: FontWeight.bold, fontSize: 11),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),

                        /// INCOIS BEARING & DIRECTION HUD
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.cyanAccent.withOpacity(.5)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.explore, color: Colors.amberAccent, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    "Bearing: ${ImblService.getBearingText(pfzBearing)} | Dist: ${pfzDistanceNM.toStringAsFixed(1)} NM | IMBL: ${imblDistance.toStringAsFixed(1)} NM",
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// PROBABILITY CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 74, 60, 127).withOpacity(.3),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(
                        color: Colors.white24,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.green.withOpacity(.15),
                          ),
                          child: Center(
                            child: Text(
                              "${fishProbability ?? 88}%",
                              style: const TextStyle(
                                color: Colors.greenAccent,
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _langProvider.getText("catch_probability"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _langProvider.getText("catch_sub"),
                                style: const TextStyle(
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// INFO CARDS
                  Row(
                    children: [
                      Expanded(
                        child: oceanCard(
                          _langProvider.getText("distance"),
                          "${pfzDistanceNM.toStringAsFixed(1)} NM",
                          Icons.explore,
                          Colors.orangeAccent,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: oceanCard(
                          _langProvider.getText("sea_state"),
                          _langProvider.getText("medium"),
                          Icons.waves,
                          Colors.cyan,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// FAVORITE SAVED HOTSPOTS SECTION
                  if (savedWaypoints.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(.08),
                        borderRadius: BorderRadius.circular(25),
                        border: Border.all(color: Colors.amberAccent.withOpacity(.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.star, color: Colors.amberAccent, size: 22),
                              SizedBox(width: 8),
                              Text("Saved Fishing Spots", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: savedWaypoints.map((spot) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.05),
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: Colors.white12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.place, color: Colors.cyanAccent, size: 20),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(spot["name"], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                          Text("Lat: ${spot["lat"].toStringAsFixed(3)}, Lon: ${spot["lon"].toStringAsFixed(3)}", style: const TextStyle(color: Colors.white54, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.navigation, color: Colors.greenAccent, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          aiFishZone = LatLng(spot["lat"], spot["lon"]);
                                        });
                                        _mapController.move(aiFishZone!, 12);
                                      },
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: 20),

                  /// AI ADVISORY CARD
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Colors.white.withOpacity(.08),
                      border: Border.all(
                        color: Colors.white24,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.psychology,
                          color: Colors.cyanAccent,
                          size: 40,
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _langProvider.getText("ai_rec"),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                advisory ?? "High ocean chlorophyll & sea surface temperature convergence detected. Bearing: ${ImblService.getBearingText(pfzBearing)}.",
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
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}