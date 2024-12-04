import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';

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

  @override
  void initState() {
    super.initState();

    // Initialize markers for each day
    dayMarkers = widget.itinerary.dailyItineraries.map((dayItinerary) {
      return dayItinerary.locations.map((location) {
        return Marker(
          markerId: MarkerId(location.name),
          position: LatLng(location.latitude, location.longitude),
          infoWindow: InfoWindow(title: location.name),
          onTap: () {
            setState(() {
              selectedLocationName = location.name;
              selectedLocationIndex = dayItinerary.locations.indexOf(location);
            });
            _zoomToLocation(selectedLocationIndex);
          },
        );
      }).toSet();
    }).toList();

    // Calculate the initial map center (average of all locations)
    _mapCenter = LatLng(
      widget.itinerary.dailyItineraries
              .expand((dayItinerary) => dayItinerary.locations)
              .map((location) => location.latitude)
              .reduce((a, b) => a + b) /
          widget.itinerary.dailyItineraries
              .expand((dayItinerary) => dayItinerary.locations)
              .length,
      widget.itinerary.dailyItineraries
              .expand((dayItinerary) => dayItinerary.locations)
              .map((location) => location.longitude)
              .reduce((a, b) => a + b) /
          widget.itinerary.dailyItineraries
              .expand((dayItinerary) => dayItinerary.locations)
              .length,
    );

    // Automatically select the first location and zoom into it when the page loads
    selectedLocationName =
        widget.itinerary.dailyItineraries[0].locations[0].name;
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
          // Display itinerary details
          // Padding(
          //   padding: const EdgeInsets.all(16.0),
          //   child: Column(
          //     crossAxisAlignment: CrossAxisAlignment.start,
          //     children: [
          //       Text(
          //         'Dates: ${formatDateRange(widget.itinerary.startDate, widget.itinerary.endDate!)}',
          //         style: TextStyle(fontSize: 18),
          //       ),
          //       Text(
          //         'Duration: ${getDuration(widget.itinerary.startDate, widget.itinerary.endDate!)}',
          //         style: TextStyle(fontSize: 18),
          //       ),
          //     ],
          //   ),
          // ),

          // Day selection buttons
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.itinerary.dailyItineraries.length,
                  (index) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      selectedDayIndex = index;
                      selectedLocationIndex = 0;
                      selectedLocationName = widget
                          .itinerary.dailyItineraries[index].locations[0].name;
                    });
                    _zoomToLocation(
                        0); // Zoom to the first location of the new day
                  },
                  child: Text(
                      'Day ${widget.itinerary.dailyItineraries[index].dayNumber}'),
                );
              }),
            ),
          ),

          // Google Map
          Expanded(
            child: Stack(
              children: [
                // Google Map
                GoogleMap(
                  onMapCreated: (GoogleMapController controller) {
                    _googleMapController = controller;

                    setState(() {
                      _isMapReady = true;
                    });
                    _zoomToLocation(0);
                  },
                  initialCameraPosition: CameraPosition(
                    target: _mapCenter,
                    zoom: 10,
                  ),
                  markers: dayMarkers[selectedDayIndex],
                ),

                // Location Cards overlay
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    height: 150,
                    margin: EdgeInsets.only(bottom: 16),
                    color:
                        Colors.transparent,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.itinerary
                          .dailyItineraries[selectedDayIndex].locations.length,
                      itemBuilder: (context, index) {
                        final location = widget
                            .itinerary
                            .dailyItineraries[selectedDayIndex]
                            .locations[index];
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLocationName = location.name;
                              selectedLocationIndex = index;
                            });
                            _zoomToLocation(
                                index); // Zoom to the selected location
                          },
                          child: Card(
                            margin: EdgeInsets.symmetric(horizontal: 8),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Container(
                              width: 250, // Wider card
                              padding: EdgeInsets.all(16),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    location.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Latitude: ${location.latitude.toStringAsFixed(2)}\nLongitude: ${location.longitude.toStringAsFixed(2)}',
                                    style: TextStyle(fontSize: 14),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
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

  // Function to zoom into the selected location
  void _zoomToLocation(int locationIndex) {
    if (_isMapReady && _googleMapController != null) {
      var location = widget.itinerary.dailyItineraries[selectedDayIndex]
          .locations[locationIndex];
      _googleMapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
            LatLng(location.latitude, location.longitude), 14),
      );
    }
  }
}
