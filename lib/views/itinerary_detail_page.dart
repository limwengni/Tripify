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
  late LatLng _mapCenter;

  List<Set<Marker>> dayMarkers = [];
  int selectedDayIndex = 0;
  String? selectedLocationName;
  int selectedLocationIndex = 0;
  bool _isMapReady = false;

  double _totalDistance = 0;
  

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
      // Fetch the locations for the itinerary from Firestore
      List<ItineraryLocation> locations =
          await _fetchLocationsForItinerary(widget.itinerary.id);

      if (locations.isEmpty) {
        print("No locations found.");
        return;
      }

      // Create markers for each location
      Set<Marker> markersForItinerary = {};
      double totalDistance = 0;

      for (int i = 0; i < locations.length; i++) {
        var location = locations[i];

        markersForItinerary.add(Marker(
          markerId: MarkerId(location.name),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(title: location.name),
          onTap: () {
            setState(() {
              selectedLocationName = location.name;
              selectedLocationIndex = locations.indexOf(location);
            });
            _zoomToLocation(location.latitude, location.longitude);
          },
        ));

        if (i < locations.length - 1) {
          var nextLocation = locations[i + 1];

          // Calculate distance between current and next location
          double distance = calculateDistance(
            location.latitude,
            location.longitude,
            nextLocation.latitude,
            nextLocation.longitude,
          );

          totalDistance += distance; // Add to total distance
        }
      }

      setState(() {
        _totalDistance = totalDistance;
      });

      for (int dayIndex = 0;
          dayIndex < widget.itinerary.numberOfDays;
          dayIndex++) {
        // Check if there are locations for this day and assign the markers
        dayMarkers[dayIndex] = markersForItinerary;
      }

      setState(() {});

      // Set the map center to the average of all locations (if there are any)
      if (locations.isNotEmpty) {
        double avgLatitude =
            locations.map((loc) => loc.latitude).reduce((a, b) => a + b) /
                locations.length;
        double avgLongitude =
            locations.map((loc) => loc.longitude).reduce((a, b) => a + b) /
                locations.length;
        _mapCenter = LatLng(avgLatitude, avgLongitude);

        firstLocationLatitude = locations[0].latitude;
        firstLocationLongitude = locations[0].longitude;
      }

      // Trigger a rebuild to reflect the changes in markers
      setState(() {});

      if (firstLocationLatitude != null && firstLocationLongitude != null) {
        _zoomToLocation(firstLocationLatitude!, firstLocationLongitude!);
      }
    } catch (e) {
      print("Error fetching locations for itinerary: $e");
    }
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
              _zoomToLocation(location.latitude, location.longitude);
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
        title: Text(widget.itinerary.name),
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
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 4.0), // Adjust spacing
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          selectedDayIndex = index;
                          selectedLocationIndex = 0;
                          selectedLocationName = null;
                        });

                        _loadInitialMarkers();

                        print(
                            "lat: $firstLocationLatitude, long: $firstLocationLongitude");

                        if (firstLocationLatitude != null &&
                            firstLocationLongitude != null) {
                          _zoomToLocation(
                              firstLocationLatitude!, firstLocationLongitude!);
                        }
                      },
                      child: Text('Day ${index + 1}'),
                    ),
                  );
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Total Distance: ${_totalDistance.toStringAsFixed(2)} km',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
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

      if (locations.isNotEmpty) {
        firstLocation = locations[0];
        print('First Location Latitude: ${firstLocation.latitude}');
        print('First Location Longitude: ${firstLocation.longitude}');
        _zoomToLocation(firstLocation.latitude, firstLocation.longitude);
      }

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
