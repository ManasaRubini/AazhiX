import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'main_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    // Show splash animation for 3 seconds
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    int lastActiveTime = prefs.getInt("lastActiveTime") ?? 0;

    int now = DateTime.now().millisecondsSinceEpoch;
    // 15 minutes threshold in milliseconds (15 * 60 * 1000)
    int maxInactivityMs = 15 * 60 * 1000;

    if (isLoggedIn && (now - lastActiveTime) <= maxInactivityMs) {
      // Refresh session timestamp and bypass login screen
      await prefs.setInt("lastActiveTime", now);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const MainScreen(),
        ),
      );
    } else {
      // Session expired or first time user -> Navigate to LoginScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// FULL SCREEN BOAT BACKGROUND
          Positioned.fill(
            child: Image.asset(
              "assets/sea_bg.png",
              fit: BoxFit.cover,
            ),
          ),

          /// DARK OCEAN OVERLAY
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(.65),
                    const Color(0xff021024).withOpacity(.55),
                    const Color(0xff0A84FF).withOpacity(.30),
                  ],
                ),
              ),
            ),
          ),

          /// WAVE EFFECT
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Opacity(
              opacity: .18,
              child: Image.asset(
                "assets/wave.png",
                fit: BoxFit.cover,
                height: 220,
              ),
            ),
          ),

          /// MAIN CONTENT
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// GLOWING LOGO
                Container(
                  width: 160,
                  height: 160,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(.10),
                    border: Border.all(
                      color: Colors.white24,
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.cyan.withOpacity(.6),
                        blurRadius: 40,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Image.asset(
                      "assets/logo_icon.png",
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                const Text(
                  "AAZHIX",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 44,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 5,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 25,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.12),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),
                  child: const Text(
                    "Smart Companion For Fishermen",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      letterSpacing: 1,
                    ),
                  ),
                ),

                const SizedBox(height: 50),

                const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}