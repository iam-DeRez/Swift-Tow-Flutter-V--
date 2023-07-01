import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:swifttow/modules/global_Variable.dart';
import '../Screens/accepted_tow_request.dart';
import '../Screens/dropOff_direction_Maps.dart';

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
}

class RideRequestNotifier {
  String nearestDriverToken = '';
  Location? driverLocation;
  String requestID = '';
  double? driverLatitude;
  double? driverLongitude;
  double? distanceValue;

  // Sending request to the nearest driver
  // void sendRideRequestToNearestDriver() async {
  //   // Creating drivers data instance
  //   final driversRef = FirebaseDatabase.instance.ref();
  //   DatabaseEvent event = await driversRef.child("drivers").once();
  //   dynamic driversData = event.snapshot.value;

  //   if (driversData != null) {
  //     // Finding nearest driver's location
  //     Location? nearestDriverLocation;
  //     double minDistance = double.infinity;

  //     driversData.forEach((key, value) {
  //       double driverLatitude1 = value['latitude'];
  //       double driverLongitude1 = value['longitude'];

  //       print('Drivers LatLong: $driverLatitude1 & $driverLongitude1');
  //       driverLatitude = driverLatitude1;
  //       driverLongitude = driverLongitude1;

  //       Location driverLocation1 =
  //           Location(latitude: driverLatitude1, longitude: driverLongitude1);
  //       driverLocation = driverLocation1;

  //       double distance = calculateDistance();

  //       if (distance < minDistance) {
  //         minDistance = distance;
  //         nearestDriverLocation = driverLocation1;
  //       }
  //     });

  //     if (nearestDriverLocation != null) {
  //       String? nearestDriverToken = await getNearestDriverToken();
  //       if (nearestDriverToken != null) {
  //         // Customize the payload as needed
  //         sendRideRequest();
  //       }
  //     }
  //   }
  // }

  // // Calculate the distance between two locations
  // calculateDistance() async {
  //   double distance = 0.0;
  //   DirectionsMapState retrieve = DirectionsMapState();
  //   double pickLat = retrieve.currentPosition.latitude;
  //   double pickLong = retrieve.currentPosition.longitude;

  //   Location userLocation = Location(latitude: pickLat, longitude: pickLong);
  //   distanceValue;
  //   Dio dio = Dio();
  //   Response response = await dio.get(
  //     "https://maps.googleapis.com/maps/api/distancematrix/json?origins=${userLocation.latitude},${userLocation.longitude}&destinations=$driverLatitude,$driverLongitude&key=$placeKey&mode=DRIVING&",
  //   );

  //   if (response.statusCode == 200) {
  //     Map<String, dynamic> data = response.data;

  //     if (data['status'] == 'OK') {
  //       var elements = data['rows'][0]['elements'];

  //       if (elements.isNotEmpty) {
  //         // var distanceText = elements[0]['distance']['text'];
  //         var distanceValue1 = elements[0]['distance']['value'];
  //         print('The distanceValue is $distanceValue');
  //         distance = distanceValue1;
  //       }
  //     }
  //   }

  //   return distance;
  // }

//Finding the nearest driver
  getNearestDriverToken() async {}

  //sending request notification to a specific driver
  Future<String> sendRideRequest() async {
    final user = FirebaseAuth.instance.currentUser;
    final userRef = FirebaseDatabase.instance.ref();

    DatabaseEvent event = await userRef.child("TowRequest/${user!.uid}").once();
    // dynamic requestData = event.snapshot.value;

    String serverKey =
        cloudServerKey; // Replace with your Firebase Cloud Messaging server key

//The request is the same as the Users Id
    final Map<String, dynamic> body = {
      "to":
          "fwmogZTcRZG7YM6qHo5xtR:APA91bEyy1PnM8gho3Ibt_RGAS2ePyJXfWWciw0TJwWO84j_gBBtTAcdL8hbTrV_MfKn7it-tCxwPVsQ39lzD0Y-apdVUWXD2x0GQJ2KSSe0ezTmuRVyCNAlpFZFvVfhXnhGJA5vtoFA",
      "notification": {
        "title": "New Tow Request",
        "body": "Tap to view request",
      },
      "data": {
        "click_action":
            "BBWA9nTg5pnWixxIjTqDvgI96FUgi1jstc063YmRwLCzrZ_AnuOxoruaMw5a4kPB6kUKauq18JQ6y1VFRPv0djs",
        "requestID": user.uid,
        "status": 'done',
        "id": 1,
      },
    };

    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'key=$serverKey',
    };

    final response = await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      print('Ride request sent successfully');
    } else {
      print('Failed to send ride request');
    }

    return requestID;
  }

  Future initialize(context) async {
    //when app is already open
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('onMessage: $message');
      // Handle incoming ride request here
      if (message.data.isNotEmpty) {
        requestedTowDriverId = message.data['towDriverId'];
        // Access request ID
        receiveTowRequestAcceptanceNotifi(context);
      }
    });

//when app is minimized
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('onResume: $message');
      // Handle resuming the app from background
      if (message.data.isNotEmpty) {
        // Access request ID
        receiveTowRequestAcceptanceNotifi(context);
      }
    });
  }

//receive acceptance notifications from drivers
  Future<void> receiveTowRequestAcceptanceNotifi(context) async {
    final driverRef = FirebaseDatabase.instance.ref();
    //Retrieving driversId request data
    DatabaseEvent event =
        await driverRef.child("drivers/$requestedTowDriverId").once();
    dynamic requestData = event.snapshot.value;

    //Drivers details
    String driversName = requestData['Name'].toString();
    String driversPhone = requestData['Phone'].toString();
    String towTruckColor = requestData['tow_truck_details']
            [requestedTowDriverId]['Tow truck color']
        .toString();
    String towTruckModel =
        requestData['tow_truck_details']['Mighty'].toString();

    print('drivers name: $driversName');
    print('Truck Color: $towTruckColor');

    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return const AcceptedTow();
    }));
  }
}
