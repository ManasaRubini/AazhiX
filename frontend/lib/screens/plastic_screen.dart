import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/plastic_service.dart';

class PlasticScreen extends StatefulWidget {
  const PlasticScreen({super.key});

  @override
  State<PlasticScreen> createState() => _PlasticScreenState();
}

class _PlasticScreenState extends State<PlasticScreen> {

  File? image;

  bool loading = false;

  bool plasticDetected = false;

  String pollutionLevel = "";

  List detections = [];

  Future<void> pickImage() async {

    final picked = await ImagePicker().pickImage(
      source: ImageSource.camera,
    );

    if (picked == null) return;

    setState(() {
      image = File(picked.path);
      loading = true;
    });

    try {

      final result =
          await PlasticService().detectPlastic(
        picked.path,
      );

      setState(() {

        plasticDetected =
            result["plastic_detected"];

        pollutionLevel =
            result["pollution_level"];

        detections =
            result["detections"];

        loading = false;
      });

    } catch (e) {

      setState(() {
        loading = false;
      });

      print(e);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    body: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color.fromARGB(255, 8, 39, 93),
            Color.fromARGB(255, 14, 68, 129),
            Color.fromARGB(255, 13, 121, 171),
          ],
        ),
      ),

      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              /// HEADER
              const Row(
                children: [

                  Icon(
                    Icons.recycling,
                    color: Colors.greenAccent,
                    size: 35,
                  ),

                  SizedBox(width: 10),

                  Text(
                    "Plastic Detection",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 25),

              /// CAPTURE BUTTON
              SizedBox(
                width: double.infinity,
                height: 60,

                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Colors.greenAccent.shade700,

                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(
                              20),
                    ),
                  ),

                  onPressed: pickImage,

                  icon: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  ),

                  label: const Text(
                    "Capture Ocean Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// IMAGE PREVIEW
              if (image != null)
                Container(
                  width: double.infinity,
                  height: 220,

                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(25),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black
                            .withOpacity(.3),
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

              const SizedBox(height: 20),

              if (loading)
                const Expanded(
                  child: Center(
                    child:
                        CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  ),
                ),

              if (!loading && image != null)
                Expanded(
                  child: ListView(
                    children: [

                      /// PLASTIC STATUS
                      resultCard(
                        "Plastic Detected",
                        plasticDetected
                            ? "YES"
                            : "NO",
                        plasticDetected
                            ? Colors.redAccent
                            : Colors.greenAccent,
                        plasticDetected
                            ? Icons.warning
                            : Icons.check_circle,
                      ),

                      resultCard(
                        "Pollution Level",
                        pollutionLevel,
                        Colors.orangeAccent,
                        Icons.waves,
                      ),

                      const SizedBox(height: 20),

                      const Text(
                        "Detected Objects",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 15),

                      ...detections.map(
                        (item) {
                          return Container(
                            margin:
                                const EdgeInsets
                                    .only(
                              bottom: 12,
                            ),

                            padding:
                                const EdgeInsets
                                    .all(18),

                            decoration:
                                BoxDecoration(
                              color: Colors.white
                                  .withOpacity(
                                      .12),

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                          20),

                              border:
                                  Border.all(
                                color: Colors
                                    .white24,
                              ),
                            ),

                            child: Row(
                              children: [

                                const CircleAvatar(
                                  backgroundColor:
                                      Colors
                                          .green,

                                  child: Icon(
                                    Icons
                                        .recycling,
                                    color:
                                        Colors
                                            .white,
                                  ),
                                ),

                                const SizedBox(
                                    width: 15),

                                Expanded(
                                  child:
                                      Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,

                                    children: [

                                      Text(
                                        item[
                                            "object"],
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white,
                                          fontWeight:
                                              FontWeight.bold,
                                          fontSize:
                                              17,
                                        ),
                                      ),

                                      const SizedBox(
                                          height:
                                              5),

                                      Text(
                                        "Confidence: ${(item["confidence"] * 100).toStringAsFixed(1)}%",
                                        style:
                                            const TextStyle(
                                          color:
                                              Colors.white70,
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
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,

                      children: const [

                        Icon(
                          Icons.camera_alt,
                          size: 90,
                          color: Colors.white54,
                        ),

                        SizedBox(height: 15),

                        Text(
                          "Capture an image to detect\nplastic pollution",
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            color:
                                Colors.white70,
                            fontSize: 18,
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
}
Widget resultCard(
  String title,
  String value,
  Color color,
  IconData icon,
) {
  return Container(
    margin: const EdgeInsets.only(
      bottom: 15,
    ),

    padding: const EdgeInsets.all(18),

    decoration: BoxDecoration(
      color: Colors.white.withOpacity(.12),

      borderRadius:
          BorderRadius.circular(20),

      border: Border.all(
        color: Colors.white24,
      ),
    ),

    child: Row(
      children: [

        Icon(
          icon,
          color: color,
          size: 30,
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
            fontSize: 16,
          ),
        ),
      ],
    ),
  );
}
}