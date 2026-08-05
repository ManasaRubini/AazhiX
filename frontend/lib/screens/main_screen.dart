import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'home_screen.dart';
import 'fishzone_screen.dart';
import 'market_screen.dart';
import 'sos_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import '../widgets/captain_voice_widget.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with WidgetsBindingObserver {
  int currentIndex = 0;

  final List<Widget> pages = [
    const HomeScreen(),
    const FishzoneScreen(),
    const SosScreen(),
    const MarketScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _updateActivityTimestamp();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _verifySessionOnResume();
    } else if (state == AppLifecycleState.paused) {
      _updateActivityTimestamp();
    }
  }

  Future<void> _updateActivityTimestamp() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt("lastActiveTime", DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> _verifySessionOnResume() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool("isLoggedIn") ?? false;
    int lastActiveTime = prefs.getInt("lastActiveTime") ?? 0;

    int now = DateTime.now().millisecondsSinceEpoch;
    int maxInactivityMs = 15 * 60 * 1000; // 15 minutes

    if (!isLoggedIn || (now - lastActiveTime) > maxInactivityMs) {
      // Session expired due to >15 mins of inactivity -> Redirect to Login
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    } else {
      // Still within 15 minutes: refresh activity timestamp
      await _updateActivityTimestamp();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      floatingActionButton: const CaptainVoiceWidget(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xff0A1628),
        selectedItemColor: Colors.cyan,
        unselectedItemColor: Colors.white54,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
        onTap: (index) {
          _updateActivityTimestamp();
          setState(() {
            currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: "Fish Zone",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sos),
            label: "SOS",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: "Market",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}