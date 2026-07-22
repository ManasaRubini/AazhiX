import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final boatController = TextEditingController();

  Future<void> saveUser() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please enter Captain Name"),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setString("name", nameController.text);
    await prefs.setString("phone", phoneController.text);
    await prefs.setString("boatId", boatController.text);
    await prefs.setBool("isLoggedIn", true);
    await prefs.setInt("lastActiveTime", DateTime.now().millisecondsSinceEpoch);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const MainScreen(),
      ),
    );
  }

  Widget buildField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Colors.white70,
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.cyanAccent,
        ),
        filled: true,
        fillColor: Colors.white.withOpacity(.08),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide(
            color: Colors.white.withOpacity(.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: const BorderSide(
            color: Colors.cyanAccent,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xff021024),
              Color(0xff063970),
              Color(0xff0A84FF),
            ],
          ),
        ),
        child: Stack(
          children: [

            /// BOAT BACKGROUND
            Positioned.fill(
              child: Opacity(
                opacity: 0.15,
                child: Image.asset(
                  "assets/sea_bg.png",
                  fit: BoxFit.cover,
                ),
              ),
            ),

            /// DARK OVERLAY
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(.25),
              ),
            ),

            /// CONTENT
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [

                      /// LOGO
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(.12),
                          border: Border.all(
                            color: Colors.white24,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.cyan.withOpacity(.4),
                              blurRadius: 30,
                              spreadRadius: 5,
                            )
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Image.asset(
                            "assets/logo_icon.png",
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "Captain Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Safe fishing starts here",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                        ),
                      ),

                      const SizedBox(height: 40),

                      /// NAME
                      buildField(
                        controller: nameController,
                        hint: "Captain Name",
                        icon: Icons.person,
                      ),

                      const SizedBox(height: 20),

                      /// PHONE
                      buildField(
                        controller: phoneController,
                        hint: "Phone Number",
                        icon: Icons.phone,
                        keyboard: TextInputType.phone,
                      ),

                      const SizedBox(height: 20),

                      /// BOAT ID
                      buildField(
                        controller: boatController,
                        hint: "Boat ID",
                        icon: Icons.directions_boat,
                      ),

                      const SizedBox(height: 35),

                      /// LOGIN BUTTON
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: InkWell(
                          onTap: saveUser,
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: const LinearGradient(
                                colors: [
                                  Color(0xff00D4FF),
                                  Color(0xff0077FF),
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.cyan.withOpacity(.4),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: const Center(
                              child: Text(
                                "LOGIN",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      const Text(
                        "AazhiX • Smart Fishing Assistant",
                        style: TextStyle(
                          color: Colors.white54,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}