import 'package:flutter/material.dart';

import 'weather_screen.dart';
import 'marine_doctor_screen.dart';
import 'fuel_screen.dart';
import 'plastic_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  /// TOP BAR
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            "assets/logo_icon.png",
                            height: 42,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "AazhiX",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white24,
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none,
                          color: Colors.white,
                        ),
                      )
                    ],
                  ),

                  const SizedBox(height: 35),

                  /// GREETING
                  const Text(
                    "Good Morning",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const Text(
                    "Captain 👋",
                    style: TextStyle(
                      color: Color(0xff4FC3FF),
                      fontSize: 52,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Safe fishing starts here",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(height: 25),

                  /// WEATHER CARD
                  Container(
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

                        const Padding(
                          padding: EdgeInsets.all(22),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 5),
                                  Text(
                                    "Chennai, India",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),

                              SizedBox(height: 20),

                              Text(
                                "28°C",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              Text(
                                "Partly Cloudy",
                                style: TextStyle(
                                  color: Colors.white70,
                                ),
                              ),

                              SizedBox(height: 10),

                              Row(
                                children: [
                                  Icon(
                                    Icons.waves,
                                    color: Colors.white,
                                  ),

                                  SizedBox(width: 6),

                                  Text(
                                    "Moderate Waves",
                                    style: TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35),

                  const Text(
                    "⚓ Quick Access",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  GridView.count(
                    shrinkWrap: true,
                    physics:
                        const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: .9,

                    children: [
                      featureCard(
                        context,
                        "Weather",
                        "Live updates",
                        Icons.cloud,
                        const Color(0xff007BFF),
                        const WeatherScreen(),
                      ),

                      featureCard(
                        context,
                        "Marine Doctor",
                        "Health advisory",
                        Icons.settings,
                        const Color(0xff00B7B7),
                        const MarineDoctorScreen(),
                      ),

                      featureCard(
                        context,
                        "Fuel Optimizer",
                        "Save fuel",
                        Icons.local_gas_station,
                        const Color(0xffFF9800),
                        const FuelScreen(),
                      ),

                      featureCard(
                        context,
                        "Plastic Alert",
                        "Keep sea clean",
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
                backgroundColor:
                    Colors.white.withOpacity(.2),
                child: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ),
            ),

            Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor:
                        Colors.black.withOpacity(.2),

                    child: Icon(
                      icon,
                      size: 45,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight:
                          FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    subtitle,
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