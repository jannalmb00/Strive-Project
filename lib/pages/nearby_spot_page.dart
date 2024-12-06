import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:strive_project/services/index.dart';

class NearbySpotPage extends StatefulWidget {
  const NearbySpotPage({super.key});

  @override
  State<NearbySpotPage> createState() => _NearbySpotPageState();
}

class _NearbySpotPageState extends State<NearbySpotPage> {
  late GoogleMapController mapController;
  LatLng _center = const LatLng(45.5017, -73.5673);  // Default to Montreal
  String latitude = '';
  String longitude = '';
  List<dynamic> cafes = [];
  List<dynamic> libraries = [];

  Set<Marker> markers = {};

  bool _showCafe = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getCurrentLocation();

  }

  Future<void>_getCurrentLocation() async{
    Position position = await LocationService.getCurrentLocation();

    setState(() {
            _center = LatLng(position.latitude, position.longitude);
            latitude = position.latitude.toString();
            longitude = position.longitude.toString();
          });

    mapController.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(position.latitude, position.longitude),
      ),
    );
    _addMarkerForCurrentLocation();
    _getNearbyPlaces(context);
  }
  void _addMarkerForCurrentLocation() {
    if (_center != null) {
      setState(() {
        markers.add(
          Marker(
            markerId: MarkerId('current_location'),
            position: _center!,
            infoWindow: InfoWindow(
              title: 'You are here',
              snippet: 'Current Location',
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueYellow), // Pink marker
          ),
        );
      });
    }
  }

  Future<void> _getNearbyPlaces(BuildContext context) async {

      try {
        List<Map<String, dynamic>> placesCafe =
        await LocationService.fetchNearbyPlaces(_center, 'cafe');

        List<Map<String, dynamic>> placesLibrary =
        await LocationService.fetchNearbyPlaces(_center, 'library');


        if (placesCafe.isNotEmpty) {

          print("Fetched ${placesCafe.length}");
          setState(() {
            cafes = placesCafe;

          });
        }
        if(placesLibrary.isNotEmpty){
          setState(() {
            libraries = placesLibrary;

          });

        }
        else {
          print('Failed to load nearby places');
          _showSnackBar(context, 'No nearby place found');
        }
      } catch (e) {
        print('Error fetching nearby places: $e');
        _showSnackBar(context, 'Error fetching : $e');
      }
    }

  Future<void> checkCache () async{

    if(cafes.isEmpty && libraries.isEmpty){
      _getNearbyPlaces(context);
    }else{
      print('Loaded');

    }

  }


  void _showSnackBar(BuildContext context, String message){
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.black54,
        )
    );
  }


  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
  }

  void _showPlaces(String type) async {
    await checkCache();

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final places = type == 'cafe' ? cafes : libraries;

        return Container(
          padding: EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${type[0].toUpperCase() + type.substring(1)}s Near You',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                // Check if places are empty
                places.isEmpty
                    ? Center(
                  child: Container(
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      'No ${type}s found nearby.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                )
                    : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: ListView.builder(
                    itemCount: places.length,
                    itemBuilder: (context, index) {
                      final place = places[index];
                      final name = place['name'] ?? 'Unnamed place';
                      final vicinity = place['vicinity'] ?? 'Unknown location';
                      final rating = place['rating']?.toString() ?? 'No rating available';
                      //final openingHours = place['opening_hours'] ?? 'No hours available';

                      return ListTile(
                        title: Text(name),
                        subtitle: Text(vicinity),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, color: Colors.amber),
                            Text(rating),
                          ],
                        ),
                        onTap: () {
                          Navigator.pop(context);
                         print( place['location']);
                         print(place['location'].latitude);


                         LatLng  visitPlace = LatLng(place['location'].latitude, place['location'].longitude);

                        if (mapController != null) {
                              mapController!.animateCamera(
                                CameraUpdate.newLatLng(visitPlace),
                              );
                        }
                          viewPlace(place);

                        setState(() {
                          markers.add(
                            Marker(
                              markerId: MarkerId(place['name'] ?? 'Unknown place'),
                              position: visitPlace,
                              infoWindow: InfoWindow(
                                title: place['name'],
                                snippet: place['vicinity'] ?? '',
                              ),
                              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose) // Customize if needed
                            ),
                          );
                        });


                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void viewPlace(Map<String, dynamic> place) async{
    bool isOpenNow = place['opening_hours'] != null ? place['opening_hours']['open_now'] : false;


    showModalBottomSheet(
        context: context,
        builder:  (BuildContext context) {
          return  Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Display the place name
                Text(
                  'Place: ${place['name'] ?? 'Unnamed place'}',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),

                // Display the vicinity (location address)
                Text(
                  'Location: ${place['vicinity'] ?? 'No location available'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),

                // Display the rating if available
                Text(
                  'Rating: ${place['rating']?.toString() ?? 'No rating available'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                SizedBox(height: 8),

                // Display the opening hours status
                Text(
                  'Open Now: ${isOpenNow ? 'Yes' : 'No'}',
                  style: TextStyle(fontSize: 16),
                ),

                // Optionally, you can display other information such as phone number, website, etc.
                place['phone'] != null
                    ? Text(
                  'Phone: ${place['phone']}',
                  style: TextStyle(fontSize: 16),
                )
                    : Container(),
                place['website'] != null
                    ? Text(
                  'Website: ${place['website']}',
                  style: TextStyle(fontSize: 16),
                )
                    : Container(),
                SizedBox(height: 16),

                // Add a button to close the modal
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the modal
                  },
                  child: Text('Close'),
                ),
              ],
            ),
          );
        });

  }



  @override
  Widget build(BuildContext context)  {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Spots'),
      ),
      body:Center(
       child:  Column(children: [
         ToggleButtons(
           isSelected: [_showCafe, !_showCafe],
           onPressed: (index) {
             setState(() {
               _showCafe = index == 0;
             });
             _showPlaces(_showCafe ? 'cafe' : 'library');
           },
           children: [
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10),
               child: Text('Cafe Shops'),
             ),
             Padding(
               padding: const EdgeInsets.symmetric(horizontal: 10),
               child: Text('Libraries'),
             ),
           ],
         ),
         SizedBox(height: 10),
         Expanded(
           child: GoogleMap(
             initialCameraPosition: CameraPosition(
               target: _center,
               zoom:19,
             ),
             markers: markers,
             onMapCreated: _onMapCreated,

             myLocationEnabled: true, //current location
             myLocationButtonEnabled: true, // Adds a button to go to the current location
           ),
         ),



       ],),
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
