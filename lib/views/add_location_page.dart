import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';

class AddLocationPage extends StatefulWidget {
  final String itineraryId;
  final int dayNumber;

  AddLocationPage({required this.itineraryId, required this.dayNumber});

  @override
  _AddLocationPageState createState() => _AddLocationPageState();
}

class _AddLocationPageState extends State<AddLocationPage>
    with SingleTickerProviderStateMixin {
  TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> filteredLocations = [];
  List<Map<String, String>> selectedLocations = [];
  bool _isLoading = false;
  final String googlePlacesApiKey = 'AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8';

  @override
  void initState() {
    super.initState();
  }

  // Add your method to search locations here
  void _filterLocations() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    setState(() {
      _isLoading = true; // Show loading while searching
    });

    // Perform the Google Places API search
    final url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=$query&key=$googlePlacesApiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List results = data['results'];

      if (results.isNotEmpty) {
        setState(() {
          filteredLocations = results
              .map<Map<String, String>>((place) => {
                    'name': place['name'],
                    'address': place['formatted_address'] ??
                        place['vicinity'] ??
                        'No address available',
                    'latitude': place['geometry']['location']['lat'].toString(),
                    'longitude':
                        place['geometry']['location']['lng'].toString(),
                  })
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          filteredLocations = []; // No results found
          _isLoading = false;
        });

        _showNoResultsDialog();
      }
    } else {
      setState(() {
        _isLoading = false;
      });
      print('Failed to search places: ${response.statusCode}');
    }
  }

  void _showNoResultsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('No Results Found'),
          content: Text('Sorry, no locations match your search.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _selectLocation(Map<String, String> location) {
    setState(() {
      // Check if location is already selected
      if (!selectedLocations.any((loc) => loc['name'] == location['name'])) {
        selectedLocations.add(location);
      }
      _searchController.clear();
      filteredLocations.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search and Add Location"),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 12),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: "Search Locations",
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: _filterLocations,
                ),
              ),
            ),
          ),

          // Display loading spinner or search results
          _isLoading
              ? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(color: Color(0xFF9F76F9)),
                )
              : filteredLocations.isEmpty
                  ? Container()
                  : Expanded(
                      child: ListView.builder(
                        itemCount: filteredLocations.length,
                        itemBuilder: (context, index) {
                          final location = filteredLocations[index];
                          return Padding(
                            padding: EdgeInsets.symmetric(
                                vertical: 2.0), // Reduce space between items
                            child: ListTile(
                              title: Text(location['name'] ?? ''),
                              subtitle: Text(location['address'] ?? ''),
                              onTap: () {
                                _selectLocation(
                                    location); // Add location to the selected list
                              },
                            ),
                          );
                        },
                      ),
                    ),

          // Display selected locations list below search bar
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(
              "Selected Locations",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          // If selected locations are not empty, show the list
          selectedLocations.isNotEmpty
              ? Padding(
                  padding: EdgeInsets.only(left: 20, right: 20),
                  child: Column(
                    children: selectedLocations.map((location) {
                      return ListTile(
                        title: Text(location['name'] ?? ''),
                        subtitle: Text(location['address'] ?? ''),
                        trailing: IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              selectedLocations.remove(location);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                )
              : Container(),
          // Save Button will only show if selectedLocations is not empty
          Visibility(
            visible: selectedLocations.isNotEmpty,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: ElevatedButton(
                onPressed: () {
                  // Call method to add locations to the itinerary
                  selectedLocations.forEach((location) {
                    _addLocationToItinerary(location, widget.dayNumber);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF9F76F9),
                  padding: EdgeInsets.symmetric(vertical: 15),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _addLocationToItinerary(
      Map<String, String> location, int dayNumber) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    WriteBatch batch = firestore.batch();

    try {
      List<String> locationIds = [];

      ItineraryLocation newLocation = ItineraryLocation(
        id: '',
        name: location['name']!,
        latitude: double.parse(location['latitude']!),
        longitude: double.parse(location['longitude']!),
      );
      Map<String, dynamic> locationMap = newLocation.toMap();

      QuerySnapshot dayItinerarySnapshot = await firestore
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: widget.itineraryId)
          .where('day_number', isEqualTo: dayNumber)
          .get();

      // Initialize `existingLocationIds` in case the DayItinerary doesn't exist
      List<String> existingLocationIds = [];

      // If DayItinerary exists
      if (dayItinerarySnapshot.docs.isNotEmpty) {
        var dayItineraryData = dayItinerarySnapshot.docs.first.data();
        Map<String, dynamic> dayItineraryMap =
            dayItineraryData as Map<String, dynamic>;

        // Safely access 'location_ids' and handle nullability
        List<String> existingLocationIds =
            List<String>.from(dayItineraryData['location_ids'] ?? []);

        // Check if any location already exists in the itinerary
        for (String locationId in existingLocationIds) {
          var locationSnapshot = await firestore
              .collection('ItineraryLocation')
              .doc(locationId)
              .get();

          if (locationSnapshot.exists) {
            var existingLocationData = locationSnapshot.data()!;
            String existingName = existingLocationData['name'];
            double existingLatitude = existingLocationData['latitude'];
            double existingLongitude = existingLocationData['longitude'];

            // Compare with the new location
            if (existingName == newLocation.name &&
                existingLatitude == newLocation.latitude &&
                existingLongitude == newLocation.longitude) {
              // If a duplicate is found, show a message and return without adding the location
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('This location is already added.'),
                  backgroundColor: Colors.orange,
                ),
              );
              return; // Stop further execution
            }
          }
        }
      }

      // If the location is not a duplicate, proceed with adding it
      DocumentReference locationRef =
          await firestore.collection('ItineraryLocation').add(locationMap);
      batch.set(locationRef, locationMap);

      // Add locationId to the list of locationIds in DayItinerary
      locationIds = List.from(existingLocationIds);
      locationIds.add(locationRef.id);

      if (dayItinerarySnapshot.docs.isEmpty) {
        // If no DayItinerary exists, create one
        DayItinerary dailyItinerary = DayItinerary(
          id: '',
          itineraryId: widget.itineraryId,
          dayNumber: dayNumber,
          locationIds: locationIds,
          createdAt: DateTime.now(),
          updatedAt: null,
        );

        Map<String, dynamic> dayItineraryMap = dailyItinerary.toMap();

        DocumentReference dayItineraryRef =
            firestore.collection('DayItinerary').doc();
        batch.set(dayItineraryRef, dayItineraryMap);
      } else {
        // If DayItinerary exists, update it by adding the new locationId to the list
        DocumentReference dayItineraryRef =
            dayItinerarySnapshot.docs.first.reference;
        batch.update(dayItineraryRef, {
          'location_ids': FieldValue.arrayUnion(locationIds),
          'updated_at': DateTime.now(),
        });
      }

      // Commit the batch
      await batch.commit();

      Navigator.pop(context, true);
    } catch (e) {
      // Handle errors
      print("Error adding locations to itinerary: $e");

      // You can also show a dialog or a snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add locations. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
