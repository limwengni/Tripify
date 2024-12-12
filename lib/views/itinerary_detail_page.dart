import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/views/view_more_page.dart';
import 'package:tripify/views/add_location_page.dart';

class ItineraryDetailPage extends StatefulWidget {
  final Itinerary itinerary;

  ItineraryDetailPage({required this.itinerary});

  @override
  _ItineraryDetailPageState createState() => _ItineraryDetailPageState();
}

class _ItineraryDetailPageState extends State<ItineraryDetailPage> {
  late GoogleMapController? _googleMapController;
  TextEditingController _nameController = TextEditingController();
  late LatLng _mapCenter;

  List<Set<Marker>> dayMarkers = [];
  int selectedDayIndex = 0;
  String? selectedLocationName;
  int selectedLocationIndex = 0;
  bool _isMapReady = false;
  bool _hasZoomedToFirstLocation = false;

  int _index = 0;
  double _totalDistance = 0;
  double dayDistance = 0;
  Map<int, double> dayDistances = {};

  double? firstLocationLatitude;
  double? firstLocationLongitude;

  late ItineraryLocation firstLocation;

  @override
  void initState() {
    super.initState();

    // Initialize markers for each day (empty initially)
    dayMarkers =
        List.generate(widget.itinerary.numberOfDays, (index) => <Marker>{});

    // Calculate the initial map center (average of all locations)
    _mapCenter = LatLng(0, 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialMarkers();
    });
  }

  void _loadInitialMarkers() async {
    try {
      dayDistance = 0;
      dayDistances.clear();
      _totalDistance = 0;

      var dayItinerarySnapshot = await FirebaseFirestore.instance
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: widget.itinerary.id)
          .get();

      if (dayItinerarySnapshot.docs.isEmpty) {
        print("No day itineraries found.");
        return;
      }

      List<Set<Marker>> markersForDays =
          List.generate(widget.itinerary.numberOfDays, (index) => <Marker>{});
      Map<int, List<ItineraryLocation>> locationsByDay = {};

      double totalDistance = 0;

      for (var dayDoc in dayItinerarySnapshot.docs) {
        var dayData = dayDoc.data();
        int dayNumber = dayData['day_number'];
        List<String> locationIds =
            List<String>.from(dayData['location_ids'] ?? []);

        List<ItineraryLocation> locationsForDay =
            await _fetchLocationsForIds(locationIds);

        locationsByDay[dayNumber] = locationsForDay;

        Set<Marker> dayMarkers = {};

        for (int i = 0; i < locationsForDay.length; i++) {
          var location = locationsForDay[i];

          dayMarkers.add(Marker(
            markerId: MarkerId(location.name),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: location.name),
            onTap: () {
              setState(() {
                selectedLocationName = location.name;
                selectedLocationIndex = locationsForDay.indexOf(location);
              });
              _zoomToLocation(location.latitude, location.longitude);
            },
          ));

          if (i < locationsForDay.length - 1) {
            var nextLocation = locationsForDay[i + 1];
            double distance = calculateDistance(
              location.latitude,
              location.longitude,
              nextLocation.latitude,
              nextLocation.longitude,
            );
            dayDistance += distance;
          }
        }

        dayDistances[dayNumber] = dayDistance;
        markersForDays[dayNumber - 1] = dayMarkers;
        _totalDistance = dayDistance;
      }

      setState(() {
        dayMarkers = markersForDays;
      });

      if (locationsByDay.isNotEmpty) {
        List<ItineraryLocation> allLocations =
            locationsByDay.values.expand((i) => i).toList();
        double avgLatitude =
            allLocations.map((loc) => loc.latitude).reduce((a, b) => a + b) /
                allLocations.length;
        double avgLongitude =
            allLocations.map((loc) => loc.longitude).reduce((a, b) => a + b) /
                allLocations.length;
        _mapCenter = LatLng(avgLatitude, avgLongitude);
        firstLocationLatitude = allLocations[0].latitude;
        firstLocationLongitude = allLocations[0].longitude;
      }

      setState(() {});

      if (firstLocationLatitude != null && firstLocationLongitude != null) {
        _zoomToLocation(firstLocationLatitude!, firstLocationLongitude!);
      }

      print("Day distances: $dayDistances");
    } catch (e) {
      print("Error fetching locations for itinerary: $e");
    }
  }

  void _showEditDialog() {
    _nameController.text =
        widget.itinerary.name; // Set the current name in the text controller

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Edit Itinerary Name"),
          content: TextField(
            controller: _nameController,
            decoration: InputDecoration(labelText: 'New Itinerary Name'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Close the dialog without doing anything
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                // Get the new name entered by the user
                String newName = _nameController.text.trim();
                if (newName.isNotEmpty) {
                  // Update the itinerary in Firestore
                  await FirebaseFirestore.instance
                      .collection('Itinerary')
                      .doc(widget.itinerary.id)
                      .update({
                    'name': newName,
                  });
                  // Close the dialog
                  Navigator.pop(context);
                  // Trigger UI update by calling setState
                  setState(() {
                    widget.itinerary.name = newName;
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF9F76F9),
                foregroundColor: Colors.white,
              ),
              child: Text("Confirm"),
            ),
          ],
        );
      },
    );
  }

  Future<List<ItineraryLocation>> _fetchLocationsForItinerary(
      String itineraryId) async {
    try {
      // Fetch all locations related to the given itineraryId
      var dayItinerarySnapshot = await FirebaseFirestore.instance
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: itineraryId)
          .get();

      if (dayItinerarySnapshot.docs.isEmpty) {
        print("No day itineraries found for itinerary ID: $itineraryId");
        return [];
      }

      List<ItineraryLocation> allLocations = [];

      for (var dayDoc in dayItinerarySnapshot.docs) {
        var dayData = dayDoc.data();
        List<String> locationIds =
            List<String>.from(dayData['location_ids'] ?? []);

        // Fetch locations using the location_ids
        List<ItineraryLocation> locationsForDay =
            await _fetchLocationsForIds(locationIds);
        allLocations.addAll(locationsForDay);

        Set<Marker> markersForDay = {};
        for (var location in locationsForDay) {
          markersForDay.add(Marker(
            markerId: MarkerId(location.name),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: location.name),
            onTap: () {
              setState(() {
                selectedLocationName = location.name;
                selectedLocationIndex = locationsForDay.indexOf(location);
              });
              // _zoomToLocation(location.latitude, location.longitude);
            },
          ));
        }

        // Assign markers for this day to the corresponding index in dayMarkers
        if (dayData['day_number'] != null && dayData['day_number'] > 0) {
          // Ensure day number is valid and within range
          int dayIndex = dayData['day_number'] - 1;
          if (dayIndex >= 0 && dayIndex < dayMarkers.length) {
            setState(() {
              dayMarkers[dayIndex] = markersForDay;
            });
          }
        }
      }
      return allLocations;
    } catch (e) {
      // Handle errors (e.g., network issues)
      print("Error fetching locations: $e");
      return [];
    }
  }

  Future<List<ItineraryLocation>> _fetchLocationsForIds(
      List<String> locationIds) async {
    try {
      // Fetch the ItineraryLocation documents using location_ids
      var locationSnapshot = await FirebaseFirestore.instance
          .collection('ItineraryLocation')
          .where(FieldPath.documentId, whereIn: locationIds)
          .get();

      List<ItineraryLocation> locations = locationSnapshot.docs.map((doc) {
        return ItineraryLocation.fromMap(doc.data(), doc.id);
      }).toList();

      return locations;
    } catch (e) {
      // Handle errors when fetching locations by IDs
      print("Error fetching locations by IDs: $e");
      return [];
    }
  }

  @override
  void dispose() {
    _googleMapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            GestureDetector(
              onTap: _showEditDialog,
              child: Text(
                widget.itinerary.name,
                style: TextStyle(fontSize: 20),
              ),
            ),
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: _showEditDialog,
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Google Map
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapController = controller;
                    setState(() {
                      _isMapReady = true;
                    });
                  },
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: 10,
                  ),
                  markers: dayMarkers[selectedDayIndex],
                ),
              ],
            ),
          ),

          // Day selection buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal, // Enable horizontal scrolling
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween, // Ensure equal spacing
                children: List.generate(widget.itinerary.numberOfDays, (index) {
                  bool isSelected = selectedDayIndex == index;

                  return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4.0), // Adjust spacing
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                isSelected ? Color(0xFF9F76F9) : Colors.grey,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: isSelected
                                  ? BorderSide(color: Color(0xFF9F76F9))
                                  : BorderSide
                                      .none, // Border for selected button
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              selectedDayIndex = index;
                              selectedLocationIndex = 0;
                              selectedLocationName = null;
                              _index = index + 1;
                            });

                            _loadInitialMarkers();

                            print(
                                "lat: $firstLocationLatitude, long: $firstLocationLongitude");

                            // if (firstLocationLatitude != null &&
                            //     firstLocationLongitude != null) {
                            //   _zoomToLocation(firstLocationLatitude!,
                            //       firstLocationLongitude!);
                            // }
                          },
                          child: Text(
                            'Day ${index + 1}',
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          )));
                }),
              ),
            ),
          ),

          // Locations list based on selected day
          Expanded(
            flex: 2,
            child: FutureBuilder<List<ItineraryLocation>>(
              future: _fetchLocationsForDay(
                  widget.itinerary.id, selectedDayIndex + 1),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF9F76F9)));
                } else if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  // If no data is available for this day, show "Add Places" button
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 16),
                      child: ElevatedButton(
                        onPressed: () {
                          _addMorePlaces(selectedDayIndex +
                              1); // Add more places for the specific day
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue),
                        child: Text("Add Places",
                            style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  );
                } else {
                  // Data is available, show locations
                  List<ItineraryLocation> locations = snapshot.data!;
                  return ListView.builder(
                    itemCount: locations.length + 1,
                    itemBuilder: (context, index) {
                      if (index < locations.length) {
                        final location = locations[index];
                        return Card(
                          margin:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          child: ListTile(
                            title: Text(location.name),
                            onTap: () {
                              _zoomToLocation(
                                  location.latitude, location.longitude);
                            },
                          ),
                        );
                      } else {
                        // This is the "Edit Places" button
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 16),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ViewMorePage(
                                    itineraryId: widget.itinerary.id,
                                    dayNumber: selectedDayIndex + 1,
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                            ),
                            child: Text(
                              "Edit Itinerary Places",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      }
                    },
                  );
                }
              },
            ),
          ),
          Text(
            'Total Distance: ${dayDistances[selectedDayIndex + 1]?.toStringAsFixed(4) ?? '0.0000'} km',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8)
        ],
      ),
    );
  }

  // Helper function to format the date range
  String formatDateRange(DateTime startDate, DateTime endDate) {
    final DateFormat formatter = DateFormat('d MMM yyyy');
    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  // Helper function to calculate the duration
  String getDuration(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    final days = difference;
    final nights = days > 0 ? days - 1 : 0;
    return '$days D $nights N';
  }

  // Fetch locations for a specific day from the database
  Future<List<ItineraryLocation>> _fetchLocationsForDay(
      String itineraryId, int dayNumber) async {
    try {
      var dayItinerarySnapshot = await FirebaseFirestore.instance
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: itineraryId)
          .where('day_number', isEqualTo: dayNumber)
          .get();

      if (dayItinerarySnapshot.docs.isEmpty) {
        return [];
      }

      var dayItineraryData = dayItinerarySnapshot.docs.first.data();
      List<String> locationIds =
          List<String>.from(dayItineraryData['location_ids'] ?? []);

      print('Location IDs: ${dayItineraryData['location_ids']}');

      List<ItineraryLocation> locations = [];

      for (String locationId in locationIds) {
        var locationSnapshot = await FirebaseFirestore.instance
            .collection('ItineraryLocation')
            .doc(locationId)
            .get();

        if (locationSnapshot.exists) {
          String documentId = locationSnapshot.id;
          var locationData = locationSnapshot.data()!;

          print("Location ID: $documentId");
          locations.add(
              ItineraryLocation.fromMap(locationData, locationSnapshot.id));
        }
      }

      // if (locations.isNotEmpty) {
      //   firstLocation = locations[0];
      //   print('First Location Latitude: ${firstLocation.latitude}');
      //   print('First Location Longitude: ${firstLocation.longitude}');
      //   _zoomToLocation(firstLocation.latitude, firstLocation.longitude);
      // }

      return locations;
    } catch (e) {
      // Handle errors
      print("Error fetching locations for day: $e");

      // You can also return an empty list in case of an error
      return [];
    }
  }

  void _addMorePlaces(int dayNumber) async {
    // Navigate to the AddLocationPage or any other page to add more places
    final selectedLocations = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLocationPage(
          itineraryId: widget.itinerary.id,
          dayNumber: dayNumber,
        ),
      ),
    );
  }

  void _addLocationsToItinerary(
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

      DocumentReference locationRef =
          await firestore.collection('ItineraryLocation').add(locationMap);

      batch.set(locationRef, locationMap);
      locationIds.add(locationRef.id);

      QuerySnapshot dayItinerarySnapshot = await firestore
          .collection('DayItinerary')
          .where('itineraryId', isEqualTo: widget.itinerary.id)
          .where('dayNumber', isEqualTo: dayNumber)
          .get();

      if (dayItinerarySnapshot.docs.isEmpty) {
        DayItinerary dailyItinerary = DayItinerary(
          id: '',
          itineraryId: widget.itinerary.id,
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
        dayItinerarySnapshot.docs.first.reference.update({
          'locationIds': FieldValue.arrayUnion(locationIds),
          'updatedAt': DateTime.now(),
        });
      }

      // Commit the batch
      await batch.commit();

      Navigator.pop(context);
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

  void _updateDayMarkers(int dayIndex, List<ItineraryLocation> locations) {
    setState(() {
      // Clear current markers for the selected day
      dayMarkers[dayIndex].clear();

      // Add new markers based on the fetched locations
      for (var location in locations) {
        dayMarkers[dayIndex].add(
          Marker(
            markerId: MarkerId(location.name),
            position: LatLng(location.latitude, location.longitude),
            infoWindow: InfoWindow(title: location.name),
            onTap: () {
              setState(() {
                selectedLocationName = location.name;
                selectedLocationIndex = locations.indexOf(location);
              });
            },
          ),
        );
      }
    });
  }

  void _zoomToLocation(double latitude, double longitude) {
    if (_googleMapController != null) {
      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(LatLng(latitude, longitude), 14),
      );
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double R = 6371; // Earth radius in kilometers

    double lat1Rad = _toRadians(lat1);
    double lon1Rad = _toRadians(lon1);
    double lat2Rad = _toRadians(lat2);
    double lon2Rad = _toRadians(lon2);

    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return R * c; // Distance in kilometers
  }

  // Function to convert degrees to radians
  double _toRadians(double degree) {
    return degree * pi / 180;
  }

  // Function to zoom into the selected location
  // void _zoomToLocation(int locationIndex) {
  //   if (_isMapReady && _googleMapController != null) {
  //     var location = widget.itinerary.dailyItineraries[selectedDayIndex]
  //         .locations[locationIndex];
  //     _googleMapController!.animateCamera(
  //       CameraUpdate.newLatLngZoom(
  //           LatLng(location.latitude, location.longitude), 14),
  //     );
  //   }
  // }
}
