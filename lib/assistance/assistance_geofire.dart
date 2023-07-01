import 'package:firebase_database/firebase_database.dart';
import 'package:swifttow/Screens/dropOff_direction_Maps.dart';

class NearbyAvailableTowDriver {
  String? key;
  double? latitude;
  double? longitude;

  NearbyAvailableTowDriver({this.key, this.latitude, this.longitude});
}

class GeoFireAssistance {
  double? driversLat;
  double? driversLong;

  static List<NearbyAvailableTowDriver> nearbyAvailableTowDriverList = [];

  static void removeTowDriverFromList(String key) {
    int index = nearbyAvailableTowDriverList
        .indexWhere((element) => element.key == key);

    nearbyAvailableTowDriverList.removeAt(index);
  }

  static void updateTowDriversPostition(NearbyAvailableTowDriver towDriver) {
    int index = nearbyAvailableTowDriverList
        .indexWhere((element) => element.key == towDriver.key);

    nearbyAvailableTowDriverList[index].latitude = towDriver.latitude;
    nearbyAvailableTowDriverList[index].longitude = towDriver.longitude;
  }

  void sendRequestToClosestDriver() {
    // Assuming you have initialized Firebase and obtained a database reference
    DatabaseReference databaseReference = FirebaseDatabase.instance.ref();
    DirectionsMapState retrieve = DirectionsMapState();

// Find the closest driver based on their latitude and longitude
    double userLatitude = retrieve.currentPosition.latitude;
    double userLongitude = retrieve.currentPosition.longitude;

//   NearbyAvailableTowDriver closestDriver = findClosestDriver(userLatitude, userLongitude);

//   // Retrieve the user's request data from the Realtime Firebase database
//   // String requestID = ...; // Replace with the user's request ID
//   // DatabaseReference requestReference = databaseReference.child('requests/$requestID');
//   // requestReference.once().then((DataSnapshot snapshot) {
//   //   // Process the user's request data
//   //   String requestData = snapshot.value['data'];

//   //   // Send the request to the closest driver
//   //   sendRequestToDriver(closestDriver, requestData);
//   // });
// }

// NearbyAvailableTowDriver findClosestDriver(double userLatitude, double userLongitude) {
//   // Assuming you have the nearbyAvailableTowDriverList initialized with driver data

//   double minDistance = double.infinity;
//   NearbyAvailableTowDriver? closestDriver;

//   for (var driver in nearbyAvailableTowDriverList) {
//     double distance = calculateDistance(userLatitude, userLongitude, driversLat!, driversLong!);
//     if (distance < minDistance) {
//       minDistance = distance;
//       closestDriver = driver;
//     }
//   }

//   return closestDriver!;
// }

// double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
//   // Implement the distance calculation logic here
//   // You can use formulas like Haversine or Vincenty's formulae
//   // to calculate the distance between two latitude-longitude points
//   // There are libraries available in Flutter for this purpose as well
//   // Return the calculated distance in meters or kilometers
// }

// void sendRequestToDriver(NearbyAvailableTowDriver driver, String requestData) {
//   // Send the request to the driver
//   // Use the driver's data and the user's request data as needed
//   // Implement your request sending logic here
// }
  }
}
