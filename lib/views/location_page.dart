import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class UserLocation extends StatefulWidget {
  @override
  _UserLocationState createState() => _UserLocationState();
}

class _UserLocationState extends State<UserLocation> {
  String? currentCountry;
@override
void initState() {
  super.initState();
  getUserCountry();
}
Future<void> checkPermissions() async {
  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Location permissions are permanently denied.");
    }
  }
  if (permission == LocationPermission.denied) {
    throw Exception("Location permissions are denied.");
  }
}

Future<void> getUserCountry() async {
  try {
    print("Checking permissions...");
    await checkPermissions();
    print("Permissions granted.");
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    print("User's Location: ${position.latitude}, ${position.longitude}");

    String country = await getCountryFromCoordinates(
      position.latitude,
      position.longitude,
    );
    print("User's Country: $country");

    setState(() {
      currentCountry = country;
    });
  } catch (e) {
    print("Error in getUserCountry: $e");
    setState(() {
      currentCountry = "Error: Unable to fetch country";
    });
  }
}


  // Method to reverse geocode coordinates and get the country
  Future<String> getCountryFromCoordinates(double lat, double lng) async {
  const String apiKey = 'AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8';
  final String url =
      'https://maps.googleapis.com/maps/api/geocode/json?latlng=$lat,$lng&key=$apiKey';

  try {
    final response = await http.get(Uri.parse(url));
    print("Response Body: ${response.body}");

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') {
        throw Exception("Error from API: ${data['error_message'] ?? data['status']}");
      }

      final results = data['results'] as List;
      if (results.isEmpty) {
        throw Exception("No results found in API response");
      }

      for (var result in results) {
        final components = result['address_components'] as List;
        for (var component in components) {
          if (component['types'] != null &&
              (component['types'] as List).contains('country')) {
            return component['long_name'];
          }
        }
      }
      throw Exception("Country not found in API response");
    } else {
      throw Exception("HTTP Error: ${response.statusCode}");
    }
  } catch (e) {
    print("Error fetching country: $e");
    return "Unknown";
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("User Country")),
      body: Center(
        child: currentCountry == null
            ? CircularProgressIndicator()
            : Text(
                "Current Country: $currentCountry",
                style: TextStyle(fontSize: 20),
              ),
      ),
    );
  }
}
