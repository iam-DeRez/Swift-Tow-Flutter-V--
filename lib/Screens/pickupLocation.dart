import 'package:flutter/material.dart';

import '../Helpers/autocompletePrediction.dart';
import '../Helpers/autocompleteresponse.dart';
import '../Helpers/network utility.dart';
import '../modules/apiKeys.dart';
import '../modules/colors.dart';
import '../modules/location list tile.dart';
import 'Maps.dart';

class PickupLocation extends StatefulWidget {
  const PickupLocation({super.key});

  @override
  State<PickupLocation> createState() => PickupLocationState();
}

class PickupLocationState extends State<PickupLocation> {
  List<AutocompletePrediction> placePrediction = [];

//getting places prediction from mapsScreen
  void getPlaces(MapScreenState mapScreen) {
    placePrediction = mapScreen
        .placePrediction; // Assigning the list variable from ClassA to the listFromA variable in ClassB
  }

//Creating an instance of mapScreen and access it data
  final MapScreenState mapScreen = MapScreenState();
  String currentAddress = MapScreenState.currentAddress;

//generating places using auto complete
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
                    press: () {});
              },
            ),
          ))
        ],
      ),
    );
  }
}
