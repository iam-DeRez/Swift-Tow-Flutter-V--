import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swifttow/modules/global_Variable.dart';

import '../assistance/AssistantMethods.dart';
import '../modules/MapBoundry.dart';
import '../modules/colors.dart';
import 'Maps.dart';

class AcceptedTow extends StatefulWidget {
  const AcceptedTow({super.key});

  @override
  State<AcceptedTow> createState() => AcceptedTowState();
}

class AcceptedTowState extends State<AcceptedTow> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;

//Latitude and Logitude for current location
  LatLng? currentPosition;

  //markers
  Set<Marker> driverMarker = {};
  Set<Marker> userLocationMarker = {};
  Set<Marker> allMarkersSet = {};

  //retrieving current and dropOff Address request Lat and Long
  String currentAddress = MapScreenState.currentAddress;
  static String dropOffAddress = '';

  //current location for main Maps
  Future locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentPosition = LatLng(position.latitude, position.longitude);
    });

    CameraPosition cameraPosition =
        CameraPosition(target: currentPosition!, zoom: 14);

    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  double mapBottomPadding = 0;
  bool visibility = true;

//Creating a variable for custom marker for driver
  BitmapDescriptor? towTruckMarker;

  //Using variable for customer marker for driver
  void createMarker() {
    if (towTruckMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'images/tow_marker.png')
          .then((icon) {
        towTruckMarker = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    locatePosition();
  }

  @override
  Widget build(BuildContext context) {
    createMarker();

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(
            color: Colors.black,
          ),
        ),
        extendBodyBehindAppBar: true,

        //Side drawer

        //body
        body: Stack(children: [
          //maps
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 290),
            markers: allMarkersSet,
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: const CameraPosition(
                target: LatLng(5.614818, -0.205874), zoom: 10),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              locatePosition();

              setState(() {
                mapBottomPadding = 290;
              });
            },
          ),

          //fare details bottomsheet
          Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
                  child: Visibility(
                    visible: visibility,
                    child: Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(25.5),
                                topRight: Radius.circular(25.5)),
                            color: Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(66, 88, 88, 88),
                                blurRadius: 25.0,
                                spreadRadius: 0.5,
                                offset: Offset(0.7, 0.7),
                              )
                            ]),
                        height: MediaQuery.of(context).size.height * 0.48,
                        child: Column(children: [
                          Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.only(
                                left: 24,
                                right: 24,
                              ),
                              child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    const Padding(
                                        padding: EdgeInsets.only(top: 24)),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: const []),
                                        const Text(
                                          "Arriving in 2 mins",
                                          style: TextStyle(
                                              fontSize: 18,
                                              letterSpacing: 1,
                                              fontWeight: FontWeight.w900),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        const Text("Amera Truck, Red",
                                            style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: 0.5,
                                                color: subtext)),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        const Divider(
                                          thickness: 1.5,
                                          color: background,
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 6,
                                    ),

                                    //container
                                    Container(
                                      padding: const EdgeInsets.only(
                                          top: 20,
                                          right: 29,
                                          left: 29,
                                          bottom: 20),
                                      width: double.infinity,
                                      decoration: const BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12)),
                                        color: gray100,
                                      ),
                                      child: Column(
                                        children: [
                                          //pickup location
                                          Row(
                                            children: [
                                              Image.asset(
                                                "images/location.png",
                                                scale: 3.5,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(
                                                currentAddress,
                                                style: const TextStyle(
                                                    color: subtext),
                                              )
                                            ],
                                          ),

                                          const SizedBox(
                                            height: 24,
                                          ),

                                          //dropOff location
                                          Row(
                                            children: [
                                              Image.asset(
                                                "images/dropOff.png",
                                                scale: 3.5,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(dropOffAddress,
                                                  style: const TextStyle(
                                                      color: subtext)),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),
                                    const Divider(
                                      thickness: 1.5,
                                      color: background,
                                    ),
                                    const SizedBox(
                                      height: 12,
                                    ),

                                    //container for actions
                                    Container(
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          InkWell(
                                            onTap: () {},
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'images/call.png',
                                                  scale: 3.7,
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                // Drivers name
                                                Text('Julius Agyei')
                                              ],
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              Image.asset(
                                                'images/call.png',
                                                scale: 3.7,
                                              ),
                                              const SizedBox(
                                                height: 8,
                                              ),
                                              // Drivers name
                                              Text('Call Driver')
                                            ],
                                          ),
                                          InkWell(
                                            onTap: () {},
                                            child: Column(
                                              children: [
                                                Image.asset(
                                                  'images/cancel.png',
                                                  scale: 3.7,
                                                ),
                                                const SizedBox(
                                                  height: 8,
                                                ),
                                                // Drivers name
                                                Text(
                                                  'Cancel Tow',
                                                  style:
                                                      TextStyle(color: danger2),
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 48,
                                    ),
                                  ]))
                        ])),
                  ))
              .animate()
              .fade(duration: const Duration(milliseconds: 600))
              .slide(
                  begin: const Offset(0, 100),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.fastLinearToSlowEaseIn),
        ]));
  }
}
