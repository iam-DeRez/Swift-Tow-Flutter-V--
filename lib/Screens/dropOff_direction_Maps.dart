import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:flutter_svg/svg.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
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

class _DirectionsMapState extends State<DirectionsMap>
    with TickerProviderStateMixin {
  //google maps controllers
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

  GoogleMapController? mapController;

  LatLng? currentLocation;

  //current location for main Maps
  Future locatePosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      currentLocation = LatLng(position.latitude, position.longitude);
    });
  }

  double mapBottomPadding = 0;
  bool visibility = true;

  //FairBottomSheet
  void hideFairBottomSheet() async {
    setState(() {
      visibility = false;
    });
  }

  //Current location
  LatLng currentPosition = MapScreenState.latlngPosition!;

  //dropOff location
  LatLng dropOffLocation = PickupLocationState.dropOffLocation!;

//polylines
  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  Map<PolylineId, Polyline> polylines = {};
  Set<Polyline> _polylines = Set<Polyline>();

//fares
  String towingPrice = '';
  String distancePrice = '';
  String totalPrice = '';

  //method for displaying distance between points
  void priceEstimate() async {
    Dio dio = Dio();
    Response response = await dio.get(
      "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${currentPosition.latitude},${currentPosition.longitude}&destinations=${dropOffLocation.latitude},${dropOffLocation.longitude}&key=$placeKey&mode=DRIVING&",
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> data = response.data;

      if (data['status'] == 'OK') {
        var elements = data['rows'][0]['elements'];

        if (elements.isNotEmpty) {
          // var distanceText = elements[0]['distance']['text'];
          var distanceValue = elements[0]['distance']['value'];
          // var durationText = elements[0]['duration']['text'];
          var durationValue = elements[0]['duration']['value'];

          // print('Distance: $distanceText');
          // print('Duration: $distanceValue');
          // print('Duration: $durationText');
          // print('Duration: $durationValue');
          setState(() {
            //calc for fare
            double basefare = 30;

            //distance fee
            double distanceFare = (distanceValue / 1000) * 0.4;
            distancePrice = distanceFare.toStringAsFixed(2).toString();
            double durationFare = (durationValue / 60) * 0.5;

            //towing fee
            double towingFee = basefare + durationFare;
            towingPrice = towingFee.toStringAsFixed(2).toString();

            //total fee
            double totalFare = basefare + distanceFare + durationFare;
            totalPrice = totalFare.toStringAsFixed(0).toString();
          });
        }
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    locatePosition();
    priceEstimate();

    super.initState();
  }

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
                  height: MediaQuery.of(context).size.height * 0.5,
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
                                    border: Border.all(
                                        width: 1, color: alertBorder),
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
                                      children: [
                                        const Text("Towing fee",
                                            style: TextStyle(color: subtext)),
                                        Text("GHc $towingPrice",
                                            style: const TextStyle(
                                                color: subtext)),
                                      ]),
                                ),

                                const SizedBox(height: 14),

                                //Distance Fare
                                Container(
                                  child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text(
                                          "Distance fee",
                                          style: TextStyle(color: subtext),
                                        ),
                                        Text("GHc $distancePrice",
                                            style: const TextStyle(
                                                color: subtext)),
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
                                      children: [
                                        const Text(
                                          "Total",
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text("GHc $totalPrice",
                                            style: const TextStyle(
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
                                      hideFairBottomSheet();
                                      showModalBottomSheet(
                                          enableDrag: false,
                                          barrierColor: Colors.transparent,
                                          backgroundColor: Colors.transparent,
                                          context: context,
                                          builder: (BuildContext context) {
                                            return const ShowPayment();
                                          });
                                      // Navigator.pushReplacement(
                                      //     context,
                                      //     MaterialPageRoute(
                                      //         builder: (context) =>
                                      //             const MapScreen()));
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
                                          borderRadius:
                                              BorderRadius.circular(30),
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
                )
                    .animate()
                    .fade(duration: const Duration(milliseconds: 600))
                    .slide(
                        begin: const Offset(0, 100),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.fastLinearToSlowEaseIn),
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

//show Payment bottom modal

class ShowPayment extends StatefulWidget {
  const ShowPayment({super.key});

  @override
  State<ShowPayment> createState() => _ShowPaymentState();
}

class _ShowPaymentState extends State<ShowPayment> {
//visibility
  bool visibility = true;

  //FairBottomSheet
  void hideFairBottomSheet() async {
    setState(() {
      visibility = false;
    });
  }

//Overiding back button
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to cancel tow request?'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), //<-- SEE HERE
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MapScreen())), // <-- SEE HERE
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
    //<-- SEE HERE
  }

  //Custom Radio Buttons
  String _selectedPayment = 'cash';
  @override
  Widget build(BuildContext context) {
    return Visibility(
      visible: visibility,
      child: WillPopScope(
        onWillPop: _onWillPop,
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
          height: MediaQuery.of(context).size.height * 0.4,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 175, right: 175, top: 10),
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
                          "Payment Method",
                          style: TextStyle(
                              fontSize: 18,
                              color: text,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),

                        const SizedBox(height: 18),

                        //Cash option
                        Container(
                          decoration: const BoxDecoration(
                              color: paymentBg,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: RadioListTile(
                            title: Row(
                              children: [
                                Image.asset('images/cash.png',
                                    width: 24,
                                    height: 24), // Replace with your image path
                                const SizedBox(width: 16),
                                const Text('Cash'),
                              ],
                            ),
                            value: 'cash',
                            groupValue: _selectedPayment,
                            onChanged: (value) {
                              setState(() {
                                _selectedPayment = value.toString();
                              });
                            },
                            activeColor: primary,
                            selected: _selectedPayment == 'cash',
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ),

                        const SizedBox(height: 24),

                        //Debit option
                        Container(
                          decoration: const BoxDecoration(
                              color: paymentBg,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10))),
                          child: RadioListTile(
                            title: Row(
                              children: [
                                Image.asset('images/debit.png',
                                    width: 24,
                                    height: 24), // Replace with your image path
                                const SizedBox(width: 16),
                                const Text('Debit or credit card'),
                              ],
                            ),
                            value: 'debit',
                            groupValue: _selectedPayment,
                            onChanged: (value) {
                              setState(() {
                                _selectedPayment = value.toString();
                              });
                            },
                            selected: _selectedPayment == 'debit',
                            controlAffinity: ListTileControlAffinity.trailing,
                          ),
                        ),

                        const SizedBox(height: 24),

                        //button
                        Container(
                            child: Column(children: [
                          ElevatedButton(
                            onPressed: () {
                              hideFairBottomSheet();
                              showModalBottomSheet(
                                  enableDrag: false,
                                  barrierColor: Colors.transparent,
                                  backgroundColor: Colors.transparent,
                                  context: context,
                                  builder: (BuildContext context) {
                                    return const showRequestBottomSheet();
                                  });
                            },
                            style: ButtonStyle(
                              elevation: MaterialStateProperty.all(0),
                              shadowColor:
                                  MaterialStateProperty.all(Colors.transparent),
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
                                "Confirm Request",
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
        ).animate().fade(duration: const Duration(milliseconds: 700)).slide(
            begin: const Offset(0, 100),
            duration: const Duration(milliseconds: 600),
            curve: Curves.fastLinearToSlowEaseIn),
      ),
    );
  }
}

//show requesting tow bottom modal

class showRequestBottomSheet extends StatefulWidget {
  const showRequestBottomSheet({super.key});

  @override
  State<showRequestBottomSheet> createState() => _showRequestBottomSheetState();
}

class _showRequestBottomSheetState extends State<showRequestBottomSheet> {
  //Overiding back button
  Future<bool> _onWillPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to cancel tow request?'),
            actions: <Widget>[
              TextButton(
                onPressed: () =>
                    Navigator.of(context).pop(false), //<-- SEE HERE
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            const MapScreen())), // <-- SEE HERE
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
    //<-- SEE HERE
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
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
        height: MediaQuery.of(context).size.height * 0.47,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 175, right: 175, top: 10),
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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //Heading
                      const Text(
                        "Requesting for Tow",
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
                          border: Border.all(width: 1, color: alert2border),
                          color: alert2bg,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                        ),
                        padding: const EdgeInsets.all(13),
                        child: Row(children: [
                          SvgPicture.asset(
                            "images/alert-circle2.svg",
                            height: 35,
                          ),
                          const SizedBox(width: 15),
                          const Flexible(
                            child: Text(
                              "Connecting you to the nearest driver .....",
                              maxLines: 3,
                            ),
                          )
                        ]),
                      ),

                      const SizedBox(height: 48),

                      LoadingAnimationWidget.inkDrop(
                        color: primary,
                        size: 70,
                      ),

                      const SizedBox(height: 48),

                      //button
                      Container(
                          child: Column(children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ButtonStyle(
                            elevation: MaterialStateProperty.all(0),
                            shadowColor:
                                MaterialStateProperty.all(Colors.transparent),
                            backgroundColor: MaterialStateProperty.all(danger2),
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
                              "Cancel Request",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 0.5,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ])),
                    ]))
          ],
        ),
      ).animate().fade(duration: const Duration(milliseconds: 700)).slide(
          begin: const Offset(0, 100),
          duration: const Duration(milliseconds: 600),
          curve: Curves.fastLinearToSlowEaseIn),
    );
  }
}



//Fare  Total fares = base far + Distance + time

