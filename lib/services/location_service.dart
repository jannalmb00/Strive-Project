import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
 class LocationService{

   static Future<Position> getCurrentLocation() async {
     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
     print("Location Service Enabled: $serviceEnabled");


     if (!serviceEnabled) {
       throw Exception('Location services are disabled');
     }

     LocationPermission permission = await Geolocator.checkPermission();
     print("Initial permission status: $permission");

     if (permission == LocationPermission.denied) {
       permission = await Geolocator.requestPermission();
       if (permission == LocationPermission.denied) {
         throw Exception('Location permission denied');
       }
     }
     if (permission == LocationPermission.deniedForever) {
       throw Exception('Location permission permanently denied');
     }

     return await Geolocator.getCurrentPosition();
   }

   static Future<List<Map<String, dynamic>>> fetchNearbyPlaces(LatLng location, String placeType) async {
     final String apiKey = 'AIzaSyB8nUnQof8e2ZzqDzYk_Lkj4jelnk6DQmw';
     final String url =
         'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=${location.latitude},${location.longitude}&radius=1000&type=$placeType&key=$apiKey';
     print("Request URL: $url");
     try {
       final response = await http.get(Uri.parse(url));

       if (response.statusCode == 200) {
         final data = json.decode(response.body);

         List<Map<String, dynamic>> places = [];
         for (var result in data['results']) {
           places.add({
             'name': result['name'],
             'location': LatLng(result['geometry']['location']['lat'], result['geometry']['location']['lng']),
             'vicinity': result['vicinity'],
             'rating': result['rating'] ?? 'No rating',
             'opening_hours': result['opening_hours'] != null
                 ? result['opening_hours']['open_now'] != null
                 ? result['opening_hours']['open_now']
                 : 'No data'
                 : 'No data',
           });
         }
         return places;
       } else {
         throw Exception('Failed to load $placeType: ${response.statusCode}');
       }
     } catch (e) {
       print("Error fetching $placeType: $e");
       throw Exception('Failed to fetch $placeType');
     }
   }


 }