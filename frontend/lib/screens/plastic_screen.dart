import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/plastic_service.dart';
import '../services/app_language_provider.dart';

class PlasticScreen extends StatefulWidget {
  const PlasticScreen({super.key});

  @override
  State<PlasticScreen> createState() => _PlasticScreenState();
}

class _PlasticScreenState extends State<PlasticScreen> {
  final AppLanguageProvider _langProvider = AppLanguageProvider();
  File? image;
  bool loading = false;
  bool plasticDetected = false;
  String pollutionLevel = "LOW";
  List detections = [];

  Future<void> showImagePickerSource() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0A1628),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.cyanAccent),
                  title: Text(_langProvider.getText("take_photo"), style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.greenAccent),
                  title: Text(_langProvider.getText("choose_gallery"), style: const TextStyle(color: Colors.white)),
                  onTap: () {
                    Navigator.pop(context);
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        imageQuality: 85,
      );

      if (picked == null) return;

      setState(() {
        image = File(picked.path);
        loading = true;
      });

      final result = await PlasticService().detectPlastic(picked.path);

      if (!mounted) return;

      setState(() {
        plasticDetected = result["plastic_detected"] ?? false;
        pollutionLevel = result["pollution_level"] ?? "LOW";
        detections = result["detections"] ?? [];
        loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error analyzing image: $e"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  String translateObject(String objName) {
    if (_langProvider.currentLanguage == "ta") {
      if (objName.contains("Debris")) return "மிதக்கும் பிளாஸ்டிக் கழிவு (Debris)";
      if (objName.contains("Bottle")) return "பிளாஸ்டிக் பாட்டில் (Plastic Bottle)";
      if (objName.contains("Container")) return "பிளாஸ்டிக் பாத்திரம் (Container)";
      if (objName.contains("Bag")) return "பிளாஸ்டிக் பைகள் (Plastic Bag)";
    }
    return objName;
  }

  Widget resultCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white24,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
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
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// HEADER (WRAPPED IN EXPANDED TO PREVENT OVERFLOW BANNER)
                    Row(
                      children: [
                        const Icon(
                          Icons.recycling,
                          color: Colors.greenAccent,
                          size: 32,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _langProvider.getText("plastic_header"),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// CAPTURE BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.greenAccent.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: showImagePickerSource,
                        icon: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                        label: Text(
                          _langProvider.getText("scan_image"),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 18),

                    /// IMAGE PREVIEW
                    if (image != null)
                      Container(
                        width: double.infinity,
                        height: 180,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(22),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(.3),
                              blurRadius: 15,
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Image.file(
                          image!,
                          fit: BoxFit.cover,
                        ),
                      ),

                    const SizedBox(height: 18),

                    if (loading)
                      const Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(color: Colors.cyanAccent),
                              SizedBox(height: 15),
                              Text(
                                "Analyzing image for plastic debris...",
                                style: TextStyle(color: Colors.white70),
                              ),
                            ],
                          ),
                        ),
                      ),

                    if (!loading && image != null)
                      Expanded(
                        child: ListView(
                          children: [
                            resultCard(
                              _langProvider.getText("plastic_detected"),
                              plasticDetected ? _langProvider.getText("yes") : _langProvider.getText("no"),
                              plasticDetected ? Colors.redAccent : Colors.greenAccent,
                              plasticDetected ? Icons.warning : Icons.check_circle,
                            ),

                            resultCard(
                              _langProvider.getText("pollution_level"),
                              pollutionLevel == "HIGH"
                                  ? _langProvider.getText("high")
                                  : pollutionLevel == "LOW"
                                      ? _langProvider.getText("low")
                                      : pollutionLevel,
                              pollutionLevel == "HIGH"
                                  ? Colors.redAccent
                                  : pollutionLevel == "MEDIUM"
                                      ? Colors.orangeAccent
                                      : Colors.greenAccent,
                              Icons.waves,
                            ),

                            const SizedBox(height: 16),

                            Text(
                              _langProvider.getText("detected_objects"),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 12),

                            if (detections.isEmpty)
                              Container(
                                padding: const EdgeInsets.all(18),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(.08),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Text(
                                    _langProvider.getText("no_plastic"),
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            else
                              ...detections.map(
                                (item) {
                                  num rawConf = item["confidence"] ?? 0.85;
                                  double confVal = rawConf.toDouble();
                                  double displayPercentage = confVal <= 1.0 ? confVal * 100 : confVal;
                                  String rawObj = item["object"]?.toString() ?? "Object";

                                  return Container(
                                    margin: const EdgeInsets.only(bottom: 10),
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.12),
                                      borderRadius: BorderRadius.circular(20),
                                      border: Border.all(
                                        color: Colors.white24,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Colors.green,
                                          child: Icon(
                                            Icons.recycling,
                                            color: Colors.white,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                translateObject(rawObj),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                "Confidence: ${displayPercentage.toStringAsFixed(1)}%",
                                                style: const TextStyle(
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                          ],
                        ),
                      ),

                    if (!loading && image == null)
                      Expanded(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.camera_alt,
                                size: 80,
                                color: Colors.white54,
                              ),
                              SizedBox(height: 15),
                              Text(
                                "Scan or select an image to detect\nmarine plastic pollution",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 17,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}