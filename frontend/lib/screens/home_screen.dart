import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../services/app_language_provider.dart';
import 'weather_screen.dart';
import 'marine_doctor_screen.dart';
import 'fuel_screen.dart';
import 'plastic_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  String captainName = "Captain";
  WeatherModel? liveWeather;
  bool loadingWeather = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadLiveWeather();
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String name = prefs.getString("name") ?? "";
    if (name.isNotEmpty) {
      setState(() {
        captainName = name;
      });
    }
  }

  Future<void> _loadLiveWeather() async {
    try {
      final data = await WeatherService().getWeather();
      if (!mounted) return;
      setState(() {
        liveWeather = data;
        loadingWeather = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingWeather = false;
      });
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
              /// Background Image
              Positioned.fill(
                child: Image.asset(
                  "assets/sea_bg.png",
                  fit: BoxFit.cover,
                ),
              ),

              /// Dark Overlay
              Positioned.fill(
                child: Container(
                  color: Colors.black.withOpacity(0.35),
                ),
              ),

              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      /// TOP BAR WITH ACTIVE NOTIFICATION BELL
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Image.asset(
                                "assets/logo_icon.png",
                                height: 42,
                              ),
                              const SizedBox(width: 10),
                              const Text(
                                "AazhiX",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const NotificationScreen(),
                                ),
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.white.withOpacity(0.12),
                                    border: Border.all(
                                      color: Colors.cyanAccent.withOpacity(0.5),
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.notifications_active,
                                    color: Colors.white,
                                    size: 26,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.redAccent,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Text(
                                      "3",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),

                      const SizedBox(height: 35),

                      /// GREETING
                      Text(
                        _langProvider.getText("welcome_back"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      Text(
                        "$captainName 👋",
                        style: const TextStyle(
                          color: Color(0xff4FC3FF),
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        _langProvider.getText("safe_fishing"),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// DYNAMIC LIVE WEATHER CARD
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WeatherScreen()),
                          );
                        },
                        child: Container(
                          height: 230,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff0A4FA8),
                                Color(0xff43C0FF),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.5),
                                blurRadius: 20,
                              )
                            ],
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                right: 15,
                                bottom: 15,
                                child: Icon(
                                  Icons.waves,
                                  size: 90,
                                  color: Colors.white.withOpacity(.25),
                                ),
                              ),

                              Padding(
                                padding: const EdgeInsets.all(22),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.location_on,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _langProvider.getText("live_weather"),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                    ),

                                    const SizedBox(height: 15),

                                    if (loadingWeather)
                                      const Expanded(
                                        child: Center(
                                          child: CircularProgressIndicator(color: Colors.white),
                                        ),
                                      )
                                    else ...[
                                      Text(
                                        "${liveWeather?.temperature ?? 29.0}°C",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 55,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),

                                      Text(
                                        liveWeather?.condition ?? "Partly Cloudy",
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 18,
                                        ),
                                      ),

                                      const SizedBox(height: 10),

                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.waves,
                                            color: Colors.white,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Wave: ${liveWeather?.waveHeight ?? 1.4}m  •  Wind: ${liveWeather?.windSpeed ?? 18.0} km/h",
                                            style: const TextStyle(
                                              color: Colors.white,
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 35),

                      Text(
                        _langProvider.getText("quick_access"),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      GridView.count(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: 2,
                        mainAxisSpacing: 18,
                        crossAxisSpacing: 18,
                        childAspectRatio: .9,
                        children: [
                          featureCard(
                            context,
                            _langProvider.getText("weather_title"),
                            _langProvider.getText("weather_sub"),
                            Icons.cloud,
                            const Color(0xff007BFF),
                            const WeatherScreen(),
                          ),

                          featureCard(
                            context,
                            _langProvider.getText("marine_doc_title"),
                            _langProvider.getText("marine_doc_sub"),
                            Icons.settings,
                            const Color(0xff00B7B7),
                            const MarineDoctorScreen(),
                          ),

                          featureCard(
                            context,
                            _langProvider.getText("fuel_title"),
                            _langProvider.getText("fuel_sub"),
                            Icons.local_gas_station,
                            const Color(0xffFF9800),
                            const FuelScreen(),
                          ),

                          featureCard(
                            context,
                            _langProvider.getText("plastic_title"),
                            _langProvider.getText("plastic_sub"),
                            Icons.recycling,
                            const Color(0xff7B4DFF),
                            const PlasticScreen(),
                          ),
                        ],
                      ),

                      const SizedBox(height: 100),
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

  Widget featureCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
    Widget screen,
  ) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => screen,
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              color,
              color.withOpacity(.7),
            ],
          ),
          border: Border.all(
            color: Colors.white24,
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 15,
              bottom: 15,
              child: CircleAvatar(
                backgroundColor: Colors.white.withOpacity(.2),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.black.withOpacity(.2),
                    child: Icon(
                      icon,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}