import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:tripify/models/emergency_calls_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyCallPage extends StatefulWidget {
  @override
  _EmergencyCallPageState createState() => _EmergencyCallPageState();
}

class _EmergencyCallPageState extends State<EmergencyCallPage> {
  FirestoreService _firestoreService = FirestoreService();
  String? currentCountry;
  EmergencyCallsModel? emergencyCallsModel;
  int generalEmergencyNumber = 112;
  @override
  void initState() {
    super.initState();
    getUserCountryAndNumber();
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

  Future<void> getUserCountryAndNumber() async {
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

      Map<String, dynamic>? emergencyCallsMap =
          await _firestoreService.getDataById('Emergency_Calls', country);
      if (emergencyCallsMap != null) {
        emergencyCallsModel = EmergencyCallsModel.fromMap(emergencyCallsMap);
      }
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
          throw Exception(
              "Error from API: ${data['error_message'] ?? data['status']}");
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
              return component[
                  'short_name']; // Use short_name for abbreviations
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
    return Center(
      child: currentCountry == null
          ? CircularProgressIndicator()
          : Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Current Country: $currentCountry",
                    style: TextStyle(fontSize: 20),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MaterialButton(
                    minWidth: double.infinity,
                    padding: const EdgeInsets.all(15),
                    color: const Color.fromARGB(255, 159, 118, 249),
                    onPressed: () => _makePhoneCall(
                        emergencyCallsModel?.fire != null
                            ? emergencyCallsModel!.police
                            : generalEmergencyNumber),
                    child: Text(
                      'Police',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MaterialButton(
                    minWidth: double.infinity,
                    padding: const EdgeInsets.all(15),
                    color: const Color.fromARGB(255, 159, 118, 249),
                    onPressed: () => _makePhoneCall(
                        emergencyCallsModel?.fire != null
                            ? emergencyCallsModel!.ambulances
                            : generalEmergencyNumber),
                    child: Text('Ambulances',
                        style: TextStyle(color: Colors.white)),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  MaterialButton(
                    minWidth: double.infinity,
                    padding: const EdgeInsets.all(15),
                    color: const Color.fromARGB(255, 159, 118, 249),
                    onPressed: () => _makePhoneCall(
                        emergencyCallsModel?.fire != null
                            ? emergencyCallsModel!.fire
                            : generalEmergencyNumber),
                    child: Text('Fire Station',
                        style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _makePhoneCall(int phoneNumber) async {
    final Uri url = Uri(scheme: 'tel', path: phoneNumber.toString());
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
