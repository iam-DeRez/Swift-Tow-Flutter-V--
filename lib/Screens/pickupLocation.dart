import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

import '../Helpers/autocompletePrediction.dart';
import '../Helpers/autocompleteresponse.dart';
import '../Helpers/network utility.dart';
import '../modules/apiKeys.dart';
import '../modules/colors.dart';
import '../modules/location list tile.dart';
import 'Maps.dart';
import 'dropOff_direction_Maps.dart';

class PickupLocation extends StatefulWidget {
  const PickupLocation({super.key});

  @override
  State<PickupLocation> createState() => PickupLocationState();
}

class PickupLocationState extends State<PickupLocation> {
  List<AutocompletePredictions> placePrediction = [];

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
  }

//getting places prediction from mapsScreen
  void getPlaces(MapScreenState mapScreen) {
    placePrediction = mapScreen
        .placePrediction; // Assigning the list variable from ClassA to the listFromA variable in ClassB
  }

//Creating an instance of mapScreen and access it data
  final MapScreenState mapScreen = MapScreenState();
  String currentAddress = MapScreenState.currentAddress;

  static LatLng? dropOffLocation;

//long and lat for selected places using auto complete
  Future placesAutoCompletee(String query) async {
    Uri uri = Uri.https("maps.googleapis.com",
        "maps/api/place/autocomplete/json", {"input": query, "key": placeKey});

    //making GET request
    String? response = await NetworkUtility.fetchUrl(uri);
    if (response != null) {
      PlaceAutoCompleteResponse result =
          PlaceAutoCompleteResponse.parseAutocompleteResult(response);
      if (result.predictions != null) {}
      setState(() {
        placePrediction = result.predictions!;
      });
    }
  }

  Future<LatLng> fetchPlaceDetails(
    String placeId,
  ) async {
    final apiKey = placeKey; // Replace with your own API key
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // Parse the JSON response
      final json = jsonDecode(response.body);
      final result = json['result'];

      // Extract the latitude and longitude from the result
      double dropOfflatitude = result['geometry']['location']['lat'];
      double drop0fflongitude = result['geometry']['location']['lng'];
      LatLng dropOffLatlng = LatLng(dropOfflatitude, drop0fflongitude);

      dropOffLocation = dropOffLatlng;
    } else {
      print(
          'Failed to fetch place details. Status code: ${response.statusCode}');
    }
    return dropOffLocation!;
  }

  @override
  Widget build(BuildContext context) {
    var dropOfflocation = mapScreen.dropOfflocation;
    return Scaffold(
      body: Column(
        children: [
          //puller
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
          ),

          //Container for holding the current location and dropOff location
          Container(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
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
                        width: MediaQuery.of(context).size.width * 0.84,
                        child: TextField(
                          enabled: false,
                          controller:
                              TextEditingController(text: currentAddress),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
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
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "Loading your location ....",
                            hintStyle:
                                const TextStyle(fontSize: 14, color: loading),
                            contentPadding: const EdgeInsets.symmetric(
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
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.84,
                      child: Container(
                        child: TextFormField(
                          onChanged: (value) {
                            placesAutoCompletee(value);
                          },
                          controller: dropOfflocation,
                          autofocus: true,
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
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: 'Your drop off location',
                            hintStyle:
                                const TextStyle(fontSize: 15, color: loading),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 13.0, horizontal: 14.0),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(
            thickness: 20,
            color: background,
          ),

          Expanded(
              child: Container(
            child: ListView.builder(
              itemCount: placePrediction.length,
              itemBuilder: (context, index) {
                return LocationListTile(
                    location: placePrediction[index].mainText!,
                    secondary: placePrediction[index].secondaryText!,
                    press: () async {
                      String placeId = placePrediction[index].placeId!;
                      await fetchPlaceDetails(placeId);
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => DirectionsMap()));
                    });
              },
            ),
          ))
        ],
      ),
    );
  }
}
