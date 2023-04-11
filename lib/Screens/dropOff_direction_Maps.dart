import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:swifttow/Screens/pickupLocation.dart';
import 'package:swifttow/modules/MapsUtils.dart';
import 'package:swifttow/modules/apiKeys.dart';
import 'package:swifttow/modules/colors.dart';

import 'Maps.dart';
import 'navDrawer.dart';

class DirectionsMap extends StatefulWidget {
  DirectionsMap({Key? key});

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
        body: Stack(children: [
          //maps
          GoogleMap(
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
            },
          ),
        ]));
  }

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
