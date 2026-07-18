import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  Widget profileTile(
    IconData icon,
    String title,
    String value,
  ) {
    return Container(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.08),

        borderRadius:
            BorderRadius.circular(25),

        border: Border.all(
          color: Colors.white24,
        ),
      ),

      child: Row(
        children: [

          Container(
            width: 50,
            height: 50,

            decoration: BoxDecoration(
              color:
                  Colors.cyan.withOpacity(.15),

              shape: BoxShape.circle,
            ),

            child: Icon(
              icon,
              color: Colors.cyanAccent,
            ),
          ),

          const SizedBox(width: 15),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  value.isEmpty
                      ? "Not Available"
                      : value,

                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight:
                        FontWeight.bold,
                    fontSize: 17,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xff041B43),

    body: Stack(
      children: [

        /// Background
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
                  children: const [

                    Icon(
                      Icons.person,
                      color: Colors.cyanAccent,
                      size: 35,
                    ),

                    SizedBox(width: 10),

                    Text(
                      "Captain Profile",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                /// PROFILE CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),

                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.08),

                    borderRadius:
                        BorderRadius.circular(30),

                    border: Border.all(
                      color: Colors.white24,
                    ),
                  ),

                  child: Column(
                    children: [

                      Container(
                        width: 110,
                        height: 110,

                        decoration: BoxDecoration(
                          shape: BoxShape.circle,

                          gradient:
                              const LinearGradient(
                            colors: [
                              Colors.cyan,
                              Colors.blue,
                            ],
                          ),
                        ),

                        child: const Icon(
                          Icons.person,
                          size: 70,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        name.isEmpty
                            ? "Captain"
                            : name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        village,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Expanded(
                  child: ListView(
                    children: [

                      profileTile(
                        Icons.person,
                        "Captain Name",
                        name,
                      ),

                      profileTile(
                        Icons.phone,
                        "Phone Number",
                        phone,
                      ),

                      profileTile(
                        Icons.directions_boat,
                        "Boat ID",
                        boatId,
                      ),

                      profileTile(
                        Icons.location_on,
                        "Village",
                        village,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                /// LOGOUT BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 60,

                  child: ElevatedButton.icon(
                    onPressed: logout,

                    style:
                        ElevatedButton.styleFrom(
                      backgroundColor:
                          Colors.redAccent,

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                                20),
                      ),
                    ),

                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                    ),

                    label: const Text(
                      "Logout",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
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
}
}