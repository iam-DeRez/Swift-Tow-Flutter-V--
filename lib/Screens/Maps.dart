import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swifttow/Helpers/autocompletePrediction.dart';

import 'package:swifttow/Screens/pickupLocation.dart';
import 'package:swifttow/assistance/assistance_geofire.dart';

import 'package:swifttow/modules/colors.dart';

import '../assistance/AssistantMethods.dart';
import 'navDrawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  //List of predictions
  List<AutocompletePredictions> placePrediction = [];

  // textcontroller
  var actualLocation = TextEditingController();
  var dropOfflocation = TextEditingController();

  //google maps controller
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  GoogleMapController? mapController;

//variables for current location, address and latlng
  Position? currentPosition;
  static String currentAddress = "";
  static LatLng? latlngPosition;

//waiting for drivers key to load up before firing - geofire on key entered
  bool nearbyTowDriversKeyLoaded = false;

  //markers
  Set<Marker> markersSet = {};

  //Current Location method
  Future locatePosition() async {
    await Geolocator.checkPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition!, zoom: 17);

    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String locality = placemarks[0].locality!;
    String subThoroughfare = placemarks[1].administrativeArea!;
    setState(() {
      currentAddress = "$locality, $subThoroughfare";
    });

    driversCallBack();
  }

  //custom markers for showing tow drivers
  BitmapDescriptor? nearbyTowMarker;

  //Creating custom markers for nearby tows
  void createMarker() {
    if (nearbyTowMarker == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(2, 2));
      BitmapDescriptor.fromAssetImage(
              imageConfiguration, 'images/tow_marker.png')
          .then((icon) {
        nearbyTowMarker = icon;
      });
    }
  }

// Getting user's token
  Future<String> getToken() async {
    final FirebaseMessaging fcm = FirebaseMessaging.instance;
    final user = FirebaseAuth.instance.currentUser!;

    String? token = await fcm.getToken();
    print("User Notification Token: $token");

    DatabaseReference tokenRef =
        FirebaseDatabase.instance.ref().child('users/${user.uid}/token');
    tokenRef.set(token);

    fcm.subscribeToTopic('all users');

    return token!;
  }

  //init state
  @override
  void initState() {
    // TODO: implement initState
    locatePosition();
    getToken();
    super.initState();
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
        drawer: const NavDrawer(),
        body: Stack(children: [
          //maps
          GoogleMap(
            markers: Set.from(markersSet),
            mapType: MapType.normal,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: false,
            initialCameraPosition: const CameraPosition(
                target: LatLng(5.614818, -0.205874), zoom: 10),
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;

              locatePosition();
            },
          ),

//bottomsheet
          Positioned(
                  left: 0,
                  bottom: 0,
                  right: 0,
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
                    height: MediaQuery.of(context).size.height * 0.3,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 175, right: 175, top: 10),
                          child: Container(
                            height: 6,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: const Color.fromARGB(255, 197, 197, 197),
                            ),
                          ),
                        ),

                        const SizedBox(
                          height: 24,
                        ),

                        //Container for holding the current location and dropOff location
                        Container(
                          padding: const EdgeInsets.only(
                              left: 16, right: 16, bottom: 32),
                          color: const Color.fromARGB(255, 255, 255, 255),

                          //
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "S3 wo car no ase3!",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: text,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),
                              const SizedBox(
                                height: 24,
                              ),

                              //current location field
                              Container(
                                height: 60,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Image.asset(
                                      'images/location.png',
                                      scale: 3.5,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: border),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: TextField(
                                        enabled: false,
                                        controller: TextEditingController(
                                            text: currentAddress),
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                        decoration: InputDecoration(
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: border,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: primary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText:
                                              "Loading your location ....",
                                          hintStyle: const TextStyle(
                                              fontSize: 14, color: loading),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 12.0,
                                                  horizontal: 14.0),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),

                              //drop off location field
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Image.asset(
                                    'images/dropOff.png',
                                    scale: 3.5,
                                  ),
                                  InkWell(
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(color: border),
                                        borderRadius:
                                            BorderRadius.circular(4.0),
                                      ),
                                      width: MediaQuery.of(context).size.width *
                                          0.84,
                                      child: TextFormField(
                                        enabled: false,
                                        controller: dropOfflocation,
                                        keyboardType:
                                            TextInputType.streetAddress,
                                        style: const TextStyle(fontSize: 15),
                                        decoration: InputDecoration(
                                          enabledBorder:
                                              const OutlineInputBorder(
                                            borderSide: BorderSide(
                                              color: border,
                                            ),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderSide: const BorderSide(
                                              color: primary,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(4.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          hintText: 'Your drop off location',
                                          hintStyle: const TextStyle(
                                              fontSize: 15, color: loading),
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  vertical: 13.0,
                                                  horizontal: 14.0),
                                        ),
                                      ),
                                    ),
                                    onTap: () {
                                      showModalBottomSheet(
                                          useSafeArea: true,
                                          isScrollControlled: true,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const PickupLocation();
                                          });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ))
              .animate()
              .fade(duration: const Duration(milliseconds: 600))
              .slide(
                  begin: const Offset(0, 100),
                  duration: const Duration(milliseconds: 1000),
                  curve: Curves.fastLinearToSlowEaseIn),
        ]));
  }

  void driversCallBack() {
    Geofire.initialize('driversAvailable');

    Geofire.queryAtLocation(
            currentPosition!.latitude, currentPosition!.longitude, 20)!
        .listen((map) {
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableTowDriver nearbyAvailableTowDrivers =
                NearbyAvailableTowDriver();
            nearbyAvailableTowDrivers.key = map['key'];
            nearbyAvailableTowDrivers.latitude = map['latitude'];
            nearbyAvailableTowDrivers.longitude = map['longitude'];
            GeoFireAssistance.nearbyAvailableTowDriverList
                .add(nearbyAvailableTowDrivers);

            if (nearbyTowDriversKeyLoaded) {
              updateAvailableDriversOnMap();
            }

            break;

          case Geofire.onKeyExited:
            GeoFireAssistance.removeTowDriverFromList(map['key']);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            // Update your key's location

            NearbyAvailableTowDriver nearbyAvailableTowDrivers =
                NearbyAvailableTowDriver();
            nearbyAvailableTowDrivers.key = map['key'];

            nearbyAvailableTowDrivers.latitude = map['latitude'];

            nearbyAvailableTowDrivers.longitude = map['longitude'];

            GeoFireAssistance.updateTowDriversPostition(
                nearbyAvailableTowDrivers);
            updateAvailableDriversOnMap();
            break;

          case Geofire.onGeoQueryReady:
            nearbyTowDriversKeyLoaded = true;
            updateAvailableDriversOnMap();
            break;
        }
      }

      setState(() {});
    });
  }

//updating available drivers on the map
  void updateAvailableDriversOnMap() {
    setState(() {
      markersSet.clear();
    });

//custom markers for drivers
    Set<Marker> tempMarkers = Set<Marker>();
    for (NearbyAvailableTowDriver nearbyAvailableTowDriver
        in GeoFireAssistance.nearbyAvailableTowDriverList) {
      LatLng towDriverPosition = LatLng(nearbyAvailableTowDriver.latitude!,
          nearbyAvailableTowDriver.longitude!);

      Marker marker = Marker(
          markerId: MarkerId("towDriver${nearbyAvailableTowDriver.key}"),
          position: towDriverPosition,
          icon: nearbyTowMarker!,
          rotation: AssistantMethods.generateRandomNumber(360));

      tempMarkers.add(marker);
    }
    setState(() {
      markersSet = tempMarkers;
    });
  }
}
