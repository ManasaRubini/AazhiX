import 'package:flutter/material.dart';

import 'package:latlong2/latlong.dart';

import 'package:flutter_map/flutter_map.dart';

import 'package:geolocator/geolocator.dart';

import '../services/fishzone_service.dart';



class FishzoneScreen extends StatefulWidget {

  const FishzoneScreen({super.key});



  @override

  State<FishzoneScreen> createState() => _FishzoneScreenState();

}



class _FishzoneScreenState extends State<FishzoneScreen> {

  final MapController _mapController = MapController();

  int? fishProbability;

  String? advisory;

  LatLng? aiFishZone;

  LatLng currentLocation = const LatLng(11.0168, 76.9558);



  final LatLng fishZone =

      const LatLng(11.0450, 76.9800);



  final LatLng plasticZone =

      const LatLng(10.9950, 76.9300);



  final LatLng harbor =

      const LatLng(11.0200, 76.9400);



  @override

  void initState() {

    super.initState();

    getCurrentLocation();

  }



  Future<void> fetchFishZoneAI() async {

    try {



      final data = await FishzoneService().getFishZone(

        currentLocation.latitude,

        currentLocation.longitude,

        "Any",

      );



      print(data); // ADD THIS



      if (!mounted) return;



      setState(() {



        fishProbability = data["fish_probability"];



        advisory = data["advisory"];



        aiFishZone = LatLng(

          (data["latitude"] as num).toDouble(),

          (data["longitude"] as num).toDouble(),

        );

      });



    } catch (e) {



      print("FishZone AI error: $e");



    }

  }

  Future<void> getCurrentLocation() async {



    LocationPermission permission = await Geolocator.checkPermission();



    if (permission == LocationPermission.denied) {

      permission = await Geolocator.requestPermission();

    }

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) return;



    Position position =

        await Geolocator.getCurrentPosition();



    currentLocation = LatLng(

      position.latitude,

      position.longitude,

    );

    

    await fetchFishZoneAI();



    _mapController.move(currentLocation, 12);



    setState(() {});

  }



  @override

  Widget build(BuildContext context) {



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

          color: Colors.black.withOpacity(.45),

        ),

      ),



      SafeArea(

        child: SingleChildScrollView(

          child: Padding(

            padding: const EdgeInsets.all(20),

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [



                /// HEADER

                Row(

                  children: [



                    Icon(

                      Icons.set_meal,

                      color: Colors.cyanAccent,

                      size: 35,

                    ),



                    SizedBox(width: 10),



                    Text(

                      "Fish Zone",

                      style: TextStyle(

                        color: Colors.white,

                        fontSize: 30,

                        fontWeight: FontWeight.bold,

                      ),

                    ),

                  ],

                ),



                SizedBox(height: 20),



                /// MAP CARD

                Container(

                  height: 320,

                  decoration: BoxDecoration(

                    borderRadius: BorderRadius.circular(30),

                    boxShadow: [

                      BoxShadow(

                        color: Colors.blue.withOpacity(.3),

                        blurRadius: 20,

                      ),

                    ],

                  ),

                  clipBehavior: Clip.antiAlias,

                  child: FlutterMap(

                    mapController: _mapController,

                    options: MapOptions(

                      initialCenter: currentLocation,

                      initialZoom: 12,

                    ),

                    children: [



                      TileLayer(
  urlTemplate:
      "https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}",
),



                      MarkerLayer(

                        markers: [



                          Marker(

                            point: currentLocation,

                            width: 50,

                            height: 50,

                            child: const Icon(

                              Icons.directions_boat,

                              color: Colors.cyan,

                              size: 40,

                            ),

                          ),



                          Marker(

                            point: aiFishZone ??

                                const LatLng(

                                    11.0450,

                                    76.9800),

                            width: 50,

                            height: 50,

                            child: Icon(

                              Icons.set_meal,

                              color: (fishProbability ?? 0) > 80

                                  ? Colors.green

                                  : Colors.orange,

                              size: 40,

                            ),

                          ),

                        ],

                      ),

                    ],

                  ),

                ),



                SizedBox(height: 25),



                /// PROBABILITY CARD

                Container(

                  padding: EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    color:  const Color.fromARGB(255, 74, 60, 127).withOpacity(.3),

                    borderRadius:

                        BorderRadius.circular(25),

                    border: Border.all(

                      color: Colors.white24,

                    ),

                  ),



                  child: Row(

                    children: [



                      Container(

                        width: 90,

                        height: 90,

                        decoration: BoxDecoration(

                          shape: BoxShape.circle,

                          color: Colors.green

                              .withOpacity(.15),

                        ),

                        child: Center(

                          child: Text(

                            "${fishProbability ?? 0}%",

                            style: TextStyle(

                              color: Colors.green,

                              fontWeight:

                                  FontWeight.bold,

                              fontSize: 24,

                            ),

                          ),

                        ),

                      ),



                      SizedBox(width: 20),



                      Expanded(

                        child: Column(

                          crossAxisAlignment:

                              CrossAxisAlignment.start,

                          children: [



                            Text(

                              "Catch Probability",

                              style: TextStyle(

                                color: Colors.white,

                                fontWeight:

                                    FontWeight.bold,

                                fontSize: 20,

                              ),

                            ),



                            SizedBox(height: 10),



                            Text(

                              "AI predicts fish concentration in this zone.",

                              style: TextStyle(

                                color: Colors.white70,

                              ),

                            ),

                          ],

                        ),

                      )

                    ],

                  ),

                ),



                SizedBox(height: 20),



                /// INFO CARDS

                Row(

                  children: [



                    Expanded(

                      child: oceanCard(

                        "Distance",

                        "8.5 km",

                        Icons.location_on,

                        Colors.orange,

                      ),

                    ),



                    SizedBox(width: 15),



                    Expanded(

                      child: oceanCard(

                        "Sea",

                        "Moderate",

                        Icons.waves,

                        Colors.cyan,

                      ),

                    ),

                  ],

                ),



                SizedBox(height: 20),



                /// AI CARD

                Container(

                  padding: EdgeInsets.all(20),

                  decoration: BoxDecoration(

                    borderRadius:

                        BorderRadius.circular(25),

                    color: Colors.white.withOpacity(.08),

                    border: Border.all(

                      color: Colors.white24,

                    ),

                  ),



                  child: Row(

                    crossAxisAlignment:

                        CrossAxisAlignment.start,

                    children: [



                      Icon(

                        Icons.psychology,

                        color: Colors.cyanAccent,

                        size: 40,

                      ),



                      SizedBox(width: 15),



                      Expanded(

                        child: Column(

                          crossAxisAlignment:

                              CrossAxisAlignment.start,

                          children: [



                            Text(

                              "AI Recommendation",

                              style: TextStyle(

                                color: Colors.white,

                                fontWeight:

                                    FontWeight.bold,

                                fontSize: 18,

                              ),

                            ),



                            SizedBox(height: 10),



                            Text(

                              advisory ??

                                  "Loading recommendation...",

                              style: TextStyle(

                                color: Colors.white70,

                                height: 1.5,

                              ),

                            ),

                          ],

                        ),

                      )

                    ],

                  ),

                ),



                SizedBox(height: 30),

              ],

            ),

          ),

        ),

      ),

    ],

  ),

);

  }



  Widget infoCard(

      String title,

      String value,

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

        mainAxisAlignment:

        MainAxisAlignment.spaceBetween,



        children: [



          Text(

            title,

            style: const TextStyle(

              color: Colors.white70,

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

  Widget oceanCard(

  String title,

  String value,

  IconData icon,

  Color color,

) {

  return Container(

    padding: const EdgeInsets.all(18),



    decoration: BoxDecoration(

      color: const Color.fromARGB(255, 74, 60, 127).withOpacity(.3),



      borderRadius:

          BorderRadius.circular(20),



      border: Border.all(

        color: const Color.fromARGB(121, 255, 255, 255),

      ),

    ),



    child: Column(

      children: [



        Icon(

          icon,

          color: color,

          size: 35,

        ),



        SizedBox(height: 10),



        Text(

          value,

          style: TextStyle(

            color: color,

            fontWeight: FontWeight.bold,

            fontSize: 18,

          ),

        ),



        SizedBox(height: 5),



        Text(

          title,

          style: TextStyle(

            color: Colors.white70,

          ),

        ),

      ],

    ),

  );

}

}