import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';

import '../services/fishzone_service.dart';
import '../services/app_language_provider.dart';

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

  LatLng currentLocation = const LatLng(10.7800, 79.1200);

  LatLng get fishZone => LatLng(currentLocation.latitude + 0.028, currentLocation.longitude + 0.024);
  LatLng get plasticZone => LatLng(currentLocation.latitude - 0.022, currentLocation.longitude - 0.026);
  LatLng get harbor => LatLng(currentLocation.latitude + 0.004, currentLocation.longitude - 0.016);

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
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
      print("FishZone AI error: $e");
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

      currentLocation = LatLng(
        position.latitude,
        position.longitude,
      );

      await fetchFishZoneAI();
      _mapController.move(currentLocation, 12);

      if (mounted) setState(() {});
    } catch (e) {
      print("Geolocator note: $e");
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
              fontSize: 18,
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
                  color: Colors.black.withOpacity(.45),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// HEADER (WRAP IN EXPANDED TO PREVENT OVERFLOW)
                      Row(
                        children: [
                          const Icon(
                            Icons.set_meal,
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
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// MAP CARD
                      Container(
                        height: 320,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(.3),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: FlutterMap(
                          mapController: _mapController,
                          options: MapOptions(
                            initialCenter: currentLocation,
                            initialZoom: 12,
                          ),
                          children: [
                            TileLayer(
                              urlTemplate: "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
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
                                  point: aiFishZone ?? LatLng(currentLocation.latitude + 0.02, currentLocation.longitude + 0.02),
                                  width: 50,
                                  height: 50,
                                  child: Icon(
                                    Icons.set_meal,
                                    color: (fishProbability ?? 0) > 80 ? Colors.green : Colors.orange,
                                    size: 40,
                                  ),
                                ),
                              ],
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
                                  "${fishProbability ?? 65}%",
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
                              "8.5 km",
                              Icons.location_on,
                              Colors.orange,
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

                      /// AI CARD
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
                                    advisory ?? _langProvider.getText("advisory"),
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
            ],
          ),
        );
      },
    );
  }
}