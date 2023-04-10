import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swifttow/Helpers/autocompletePrediction.dart';

import 'package:swifttow/Screens/pickupLocation.dart';

import 'package:swifttow/modules/colors.dart';

import 'navDrawer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => MapScreenState();
}

class MapScreenState extends State<MapScreen> {
  List<AutocompletePrediction> placePrediction = [];

  //google maps controller
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;

  Position? currentPosition;
  static String currentAddress = "";
  var geoLocator = Geolocator();

//query for

  @override
  void initState() {
    // TODO: implement initState
    locatePosition(context);

    super.initState();
  }

  //Current Location
  Future locatePosition(BuildContext context, [bool mounted = true]) async {
    showDialog(
        // The user CANNOT close this dialog  by pressing outsite it
        barrierDismissible: false,
        context: context,
        builder: (_) {
          return Dialog(
            // The background color
            backgroundColor: Colors.white,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  // The loading indicator
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 15,
                  ),
                  // Some text
                  Text('Loading...')
                ],
              ),
            ),
          );
        });

    await Geolocator.checkPermission();

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    currentPosition = position;

    LatLng latlngPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latlngPosition, zoom: 17);

    mapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    String locality = placemarks[0].locality!;
    String subThoroughfare = placemarks[1].administrativeArea!;
    setState(() {
      currentAddress = "$locality, $subThoroughfare";
    });

    if (!mounted) return;
    Navigator.of(context).pop();
  }

//Place Autocomplete

  // textcontroller
  var actualLocation = TextEditingController();
  var dropOfflocation = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

              locatePosition(context);
            },
          ),

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

                //puller
                child: Column(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.only(left: 175, right: 175, top: 10),
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
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Image.asset(
                                  'images/location.png',
                                  scale: 3.5,
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: border),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.84,
                                  child: TextField(
                                    enabled: false,
                                    controller: TextEditingController(
                                        text: currentAddress),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
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
                                      hintText: "Loading your location ....",
                                      hintStyle: const TextStyle(
                                          fontSize: 14, color: loading),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                              vertical: 12.0, horizontal: 14.0),
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Image.asset(
                                'images/dropOff.png',
                                scale: 3.5,
                              ),
                              InkWell(
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: border),
                                    borderRadius: BorderRadius.circular(4.0),
                                  ),
                                  width:
                                      MediaQuery.of(context).size.width * 0.84,
                                  child: TextFormField(
                                    enabled: false,
                                    controller: dropOfflocation,
                                    keyboardType: TextInputType.streetAddress,
                                    style: const TextStyle(fontSize: 15),
                                    decoration: InputDecoration(
                                      enabledBorder: const OutlineInputBorder(
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
                                              vertical: 13.0, horizontal: 14.0),
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
              )),
        ]));
  }
}
