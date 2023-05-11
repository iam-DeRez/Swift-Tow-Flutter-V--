import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swifttow/Screens/pickupLocation.dart';
import 'package:swifttow/modules/MapBoundry.dart';
import 'package:swifttow/modules/apiKeys.dart';
import 'package:swifttow/modules/colors.dart';

import 'Maps.dart';
import 'navDrawer.dart';

class DirectionsMap extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const DirectionsMap({Key? key});

  @override
  State<DirectionsMap> createState() => _DirectionsMapState();
  //google maps controller
}

class _DirectionsMapState extends State<DirectionsMap> {
  @override
  void initState() {
    // TODO: implement initState
    locatePosition();

    super.initState();
  }

  //google maps controllers
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;

  LatLng? currentLocation;

  //current location
  Future locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  double mapBottomPadding = 0;

  //dropOff location
  LatLng currentPosition = MapScreenState.latlngPosition!;
  LatLng dropOffLocation = PickupLocationState.dropOffLocation!;

//polylines
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Set<Polyline> _polylines = Set<Polyline>();

  @override
  Widget build(BuildContext context) {
    //Current Location and DropOffLocation markers
    Set<Marker> markers = {
      //currentLocation marker

      Marker(
          markerId: const MarkerId("CurrentLocation"),
          position: currentLocation!),

      //dropOffLocation marker
      Marker(
        markerId: const MarkerId("DropOffLocation"),
        position: dropOffLocation,
      )
    };

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

        //body
        body: Stack(children: [
          //maps
          GoogleMap(
            padding: const EdgeInsets.only(bottom: 290),
            markers: Set.from(markers),
            polylines: _polylines,
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
              Future.delayed(
                  const Duration(milliseconds: 200),
                  () => controller.animateCamera(CameraUpdate.newLatLngBounds(
                      MapUtil.boundsFromLatLngList(
                          markers.map((loc) => loc.position).toList()),
                      1)));

              setPolylines();
              setState(() {
                mapBottomPadding = 290;
              });
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
                height: MediaQuery.of(context).size.height * 0.5,
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

                      //Container for bottomsheet
                    ),
                    Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.only(
                          left: 24,
                          right: 24,
                        ),

                        //Column layout
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              //Heading
                              const Text(
                                "Normal Towing",
                                style: TextStyle(
                                    fontSize: 18,
                                    color: text,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1),
                              ),

                              const SizedBox(height: 18),

                              //Alert
                              Container(
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(width: 1, color: alertBorder),
                                  color: alertBg,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(10)),
                                ),
                                padding: const EdgeInsets.all(13),
                                child: Row(children: [
                                  SvgPicture.asset(
                                    "images/alert-circle.svg",
                                    height: 35,
                                  ),
                                  const SizedBox(width: 15),
                                  const Flexible(
                                    child: Text(
                                      "Please hold on tight trucks are available. T for thanks",
                                      maxLines: 3,
                                    ),
                                  )
                                ]),
                              ),

                              const SizedBox(height: 24),

                              //Towing Fare
                              Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text("Towing fee",
                                          style: TextStyle(color: subtext)),
                                      Text("GHs 200",
                                          style: TextStyle(color: subtext)),
                                    ]),
                              ),

                              const SizedBox(height: 14),

                              //Distance Fare
                              Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Distance fee",
                                        style: TextStyle(color: subtext),
                                      ),
                                      Text("GHs 30",
                                          style: TextStyle(color: subtext)),
                                    ]),
                              ),

                              const SizedBox(height: 24),
                              const Divider(
                                height: 1,
                                color: text,
                              ),

                              const SizedBox(height: 12),
                              //Total fare
                              Container(
                                child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: const [
                                      Text(
                                        "Total",
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("GHs 230",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold)),
                                    ]),
                              ),

                              const SizedBox(height: 42),

                              //button
                              Container(
                                  child: Column(children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                const MapScreen()));
                                  },
                                  style: ButtonStyle(
                                    elevation: MaterialStateProperty.all(0),
                                    shadowColor: MaterialStateProperty.all(
                                        Colors.transparent),
                                    backgroundColor:
                                        MaterialStateProperty.all(primary),
                                    minimumSize: MaterialStateProperty.all(
                                        const Size(double.infinity, 55)),
                                    shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                    ),
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text(
                                      "Continue",
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.5,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                              ])),
                            ])),
                  ],
                ),
              )),
        ]));
  }

//Polylines function
  void setPolylines() async {
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      placeKey,
      PointLatLng(currentPosition.latitude, currentPosition.longitude),
      PointLatLng(dropOffLocation.latitude, dropOffLocation.longitude),
      travelMode: TravelMode.driving,
    );

    if (result.points.isNotEmpty) {
      result.points.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });

      setState(() {
        _polylines.add(Polyline(
            polylineId: const PolylineId("poly"),
            color: primary,
            width: 4,
            points: polylineCoordinates));
      });
    }
  }
}
