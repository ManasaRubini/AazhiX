import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import '../services/app_language_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  String name = "";
  String phone = "";
  String boatId = "";
  String village = "Nagapattinam";

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString("name") ?? "";
      phone = prefs.getString("phone") ?? "";
      boatId = prefs.getString("boatId") ?? "";
      village = prefs.getString("village") ?? "Nagapattinam";
    });
  }

  Future<void> logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff0A2246),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text(
            _langProvider.getText("language_setting"),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: AppLanguageProvider.languageNames.entries.map((entry) {
              bool isSelected = _langProvider.currentLanguage == entry.key;
              return ListTile(
                title: Text(
                  entry.value,
                  style: TextStyle(
                    color: isSelected ? Colors.cyanAccent : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                trailing: isSelected ? const Icon(Icons.check, color: Colors.cyanAccent) : null,
                onTap: () async {
                  await _langProvider.setLanguage(entry.key);
                  if (!mounted) return;
                  Navigator.pop(context);
                },
              );
            }).toList(),
          ),
        );
      },
    );
  }

  void _showPrivacyPolicy() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff0A2246),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text(
            _langProvider.getText("privacy_policy"),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "AazhiX is committed to protecting fisherman location data and vessel security.\n\n"
              "1. Location Data: GPS coordinates are used exclusively for real-time weather forecasts, PFZ mapping, and emergency Coast Guard dispatch.\n"
              "2. Audio Diagnostics: Engine sound recordings are analyzed strictly for machinery health and are never stored for commercial marketing.\n"
              "3. Emergency Signals: SOS signals transmit coordinates directly to authorized emergency contact networks.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close", style: TextStyle(color: Colors.cyanAccent)),
            )
          ],
        );
      },
    );
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xff0A2246),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: Text(
            _langProvider.getText("disclaimer"),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: const SingleChildScrollView(
            child: Text(
              "Maritime Safety Notice:\n\n"
              "AazhiX AI predictions (Potential Fishing Zones, Wave Height Forecasts, Engine Health Advisory) serve as supportive navigational tools.\n"
              "Captains are advised to combine AazhiX insights with official Coast Guard radio bulletins and maritime port authority regulations.",
              style: TextStyle(color: Colors.white70, height: 1.5),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Understand & Agree", style: TextStyle(color: Colors.cyanAccent)),
            )
          ],
        );
      },
    );
  }

  Widget profileTile({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    Widget? trailing,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(.08),
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.white24),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: Colors.cyan.withOpacity(.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: Colors.cyanAccent),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value.isEmpty ? "Not Available" : value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
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
                  color: Colors.black.withOpacity(.55),
                ),
              ),

              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      /// HEADER
                      Row(
                        children: [
                          const Icon(Icons.person, color: Colors.cyanAccent, size: 32),
                          const SizedBox(width: 10),
                          Text(
                            _langProvider.getText("profile"),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// PROFILE CARD
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(22),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.08),
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.white24),
                        ),
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [Colors.cyan, Colors.blue],
                                ),
                              ),
                              child: const Icon(Icons.person, size: 55, color: Colors.white),
                            ),
                            const SizedBox(height: 15),
                            Text(
                              name.isEmpty ? "Captain" : name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              village,
                              style: const TextStyle(color: Colors.white70, fontSize: 15),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      Expanded(
                        child: ListView(
                          children: [
                            profileTile(
                              icon: Icons.language,
                              title: _langProvider.getText("language_setting"),
                              value: AppLanguageProvider.languageNames[_langProvider.currentLanguage] ?? "English",
                              onTap: _showLanguageDialog,
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.cyanAccent, size: 18),
                            ),
                            profileTile(
                              icon: Icons.person_outline,
                              title: "Captain Name",
                              value: name,
                            ),
                            profileTile(
                              icon: Icons.phone,
                              title: "Phone Number",
                              value: phone,
                            ),
                            profileTile(
                              icon: Icons.directions_boat,
                              title: "Boat ID",
                              value: boatId,
                            ),
                            profileTile(
                              icon: Icons.privacy_tip_outlined,
                              title: _langProvider.getText("privacy_policy"),
                              value: "Read Policies",
                              onTap: _showPrivacyPolicy,
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                            ),
                            profileTile(
                              icon: Icons.gavel_outlined,
                              title: _langProvider.getText("disclaimer"),
                              value: "Safety Guidance",
                              onTap: _showDisclaimer,
                              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 18),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      Text(
                        _langProvider.getText("version"),
                        style: const TextStyle(color: Colors.white54, fontSize: 12),
                      ),

                      const SizedBox(height: 12),

                      /// LOGOUT BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton.icon(
                          onPressed: logout,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          icon: const Icon(Icons.logout, color: Colors.white),
                          label: Text(
                            _langProvider.getText("logout"),
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
              ),
            ],
          ),
        );
      },
    );
  }
}