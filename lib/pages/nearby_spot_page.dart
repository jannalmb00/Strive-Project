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



  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  // Boolean to show cafes by default
  bool _showCafe = true;

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await LocationService.getCurrentLocation();

      setState(() {
        _center = LatLng(position.latitude, position.longitude);
        latitude = position.latitude.toString();
        longitude = position.longitude.toString();
      });

      // Move the camera to the current location
      if (mapController != null) {
        mapController!.animateCamera(
          CameraUpdate.newLatLng(_center),
        );
      }
    } catch (e) {
      print("Error getting location: $e");

      _showSnackBar(context, "Error getting location");
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    _getCurrentLocation();
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

  Future<void> _getNearbyPlaces(String type, BuildContext Context) async {

    try {
      List<Map<String, dynamic>> places =
      await LocationService.fetchNearbyPlaces(_center, type);


      if (places.isNotEmpty) {
        print("Fetched ${places.length} $type(s).");
        setState(() {
          if (type == 'cafe') {
            //_showSnackBar(context, data.toString());
            cafes = places;
          } else {
            // _showSnackBar(context, type);
            libraries = places;
          }
        });
      } else {
        print('Failed to load nearby places');
        _showSnackBar(context, 'No nearby $type found');
      }
    } catch (e) {
      print('Error fetching nearby places: $e');
      _showSnackBar(context, 'Error fetching nearby $type: $e');
    }
  }

  void _addMarker(String placeName, LatLng location) {
    final marker = Marker(
      markerId: MarkerId(placeName),
      position: location,
      infoWindow: InfoWindow(title: placeName),
    );

    setState(() {
      markers.add(marker);
    });
  }

  void _showPlaces(String type) async {
    await _getNearbyPlaces(type, context);

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        final places = type == 'cafe' ? cafes : libraries;

        return Container(
          padding: EdgeInsets.all(16.0),
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
                  : ListView.builder(
                itemCount: places.length,
                itemBuilder: (context, index) {
                  final place = places[index];
                  _showSnackBar(context,  places.length.toString());

                  final name = place['name'] ?? 'Unnamed place';
                  final vicinity = place['vicinity'] ?? 'Unknown location';
                  final rating = place['rating']?.toString() ?? 'No rating available';
                  final openingHours = place['opening_hours'] ?? 'No hours available';

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
                      _addMarker(place['name'], place['location']);

                      // info of the place
                      showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Name: $name'),
                                Text('Rating: $rating'),
                                Text('Location: $vicinity'),
                                Text('Opening Hours: $openingHours'),
                                SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    _addMarker(place['name'], place['location']);
                                    Navigator.pop(context); // Close the bottom sheet
                                  },
                                  child: Text('View on Map'),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }



  Widget _recenterButton() {
    return ElevatedButton(
      onPressed: _getCurrentLocation ,
      child: const Text('Recenter'),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Spots'),
      ),
      body: Column(
        children: [
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
                zoom: 18,
              ),
              onMapCreated: _onMapCreated,
              myLocationEnabled: true, //current location
              myLocationButtonEnabled: true, // Adds a button to go to the current location
            ),
          ),
        ],
      ),
      floatingActionButton: _recenterButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
