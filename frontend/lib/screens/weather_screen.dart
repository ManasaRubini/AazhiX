import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {

  late Future<WeatherModel> weather;

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() {
    setState(() {
      weather = WeatherService().getWeather();
    });
  }

  Widget weatherCard(
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
            child: Icon(
              icon,
              color: color,
            ),
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
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color.fromARGB(255, 8, 39, 93),
              Color.fromARGB(255, 14, 68, 129),
              Color.fromARGB(255, 13, 121, 171),
            ],
          ),
        ),

        child: SafeArea(
          child: FutureBuilder<WeatherModel>(
            future: weather,

            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.cyanAccent),
                      SizedBox(height: 15),
                      Text(
                        "Connecting to Ocean Weather Service...",
                        style: TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                );
              }

              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.cloud_off, size: 60, color: Colors.orangeAccent),
                        const SizedBox(height: 15),
                        const Text(
                          "Failed to load weather",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Please check your internet connection or try again.",
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white70),
                        ),
                        const SizedBox(height: 25),
                        ElevatedButton.icon(
                          onPressed: _fetchWeather,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          ),
                          icon: const Icon(Icons.refresh),
                          label: const Text("Retry"),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final data = snapshot.data!;

              return RefreshIndicator(
                onRefresh: () async {
                  _fetchWeather();
                },
                child: Padding(
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      /// HEADER
                      const Row(
                        children: [

                          Icon(
                            Icons.wb_sunny,
                            color: Colors.yellow,
                            size: 35,
                          ),

                          SizedBox(width: 10),

                          Text(
                            "Weather Forecast",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// MAIN WEATHER CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(25),

                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),

                          gradient: const LinearGradient(
                            colors: [
                              Color(0xff2196F3),
                              Color(0xff64B5F6),
                            ],
                          ),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(.4),
                              blurRadius: 25,
                            ),
                          ],
                        ),

                        child: Column(
                          children: [

                            const Icon(
                              Icons.cloud,
                              color: Colors.white,
                              size: 70,
                            ),

                            const SizedBox(height: 10),

                            Text(
                              "${data.temperature}°C",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 55,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            Text(
                              data.condition,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      Expanded(
                        child: ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [

                            weatherCard(
                              "Humidity",
                              "${data.humidity} %",
                              Icons.water_drop,
                              Colors.blueAccent,
                            ),

                            weatherCard(
                              "Wind Speed",
                              "${data.windSpeed} km/h",
                              Icons.air,
                              Colors.greenAccent,
                            ),

                            weatherCard(
                              "Wave Height",
                              "${data.waveHeight} m",
                              Icons.waves,
                              Colors.cyanAccent,
                            ),

                            weatherCard(
                              "Condition",
                              data.condition,
                              Icons.cloud,
                              Colors.orangeAccent,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}