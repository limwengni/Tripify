import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SelectLocationPage extends StatefulWidget {
  @override
  _SelectLocationPageState createState() => _SelectLocationPageState();
}

class _SelectLocationPageState extends State<SelectLocationPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> filteredLocations = [];
  Position? _currentPosition;
  final String googlePlacesApiKey = 'AIzaSyBKL2cfygOtYMNsbA8lMz84HrNnAAHAkc8';
  bool _dialogShown = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _filterLocations();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Handle service not enabled by showing a dialog
      if (!_dialogShown) {
        _dialogShown = true;
        await _showLocationServiceDialog();
      }
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Show the permission dialog
        if (!_dialogShown) {
          _dialogShown = true;
          await _showPermissionDialog();
        }
        return;
      }
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    setState(() {
      _currentPosition = position;
    });

    // Fetch nearby places
    if (_currentPosition != null) {
      _fetchNearbyPlaces(
          _currentPosition!.latitude, _currentPosition!.longitude);
    }
  }

  Future<void> _showLocationServiceDialog() async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dialogBackgroundColor = isDarkMode ? Color(0xFF333333) : Colors.white;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            "Location Services Disabled",
            style: TextStyle(color: textColor),
          ),
          content: Text(
            "Please enable location services to proceed.",
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              child: Text("OK", style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showPermissionDialog() async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dialogBackgroundColor = isDarkMode ? Color(0xFF333333) : Colors.white;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            "Permission Required",
            style: TextStyle(color: textColor),
          ),
          content: Text(
            "We need access to your location to proceed. Please enable the permission in your app settings.",
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              child: Text("Cancel", style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Open Settings", style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openAppSettings(); // Open app settings
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _fetchNearbyPlaces(double latitude, double longitude) async {
    String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json?query=places+near+me&location=$latitude,$longitude&radius=500&key=$googlePlacesApiKey';

    List<Map<String, String>> locations = [];
    bool hasNextPage = true;

    setState(() {
      _isLoading = true; // Start loading
    });

    while (hasNextPage) {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List results = data['results'];

        locations.addAll(results.map<Map<String, String>>((place) {
          return {
            'name': place['name'],
            'address': place['formatted_address'] ??
                place['vicinity'] ??
                'No address available',
          };
        }).toList());

        // Check if there is a next page
        if (data['next_page_token'] != null) {
          // Wait a short time before requesting the next page
          await Future.delayed(Duration(seconds: 2));
          url =
              'https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=$latitude,$longitude&radius=500&key=$googlePlacesApiKey&pagetoken=${data['next_page_token']}';
        } else {
          hasNextPage = false;
        }
      } else {
        print('Failed to load places: ${response.statusCode}');
        hasNextPage = false;
      }
    }

    setState(() {
      filteredLocations = locations;
      _isLoading = false;
    });
  }

  // Filter locations based on search text
  void _filterLocations() async {
    final query = _searchController.text.trim();

    if (query.isEmpty) return;

    setState(() {
      _isLoading = true; // Show loading while searching
    });

    final filtered = filteredLocations
        .where((location) =>
            location['name']!.toLowerCase().contains(query.toLowerCase()))
        .toList();

    if (filtered.isNotEmpty) {
      setState(() {
        filteredLocations = filtered;
        _isLoading = false;
      });
      return;
    }

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

    print('Filtered Locations: $filteredLocations');
  }

  Future<void> _showNoResultsDialog() async {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final dialogBackgroundColor = isDarkMode ? Color(0xFF333333) : Colors.white;

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: dialogBackgroundColor,
          title: Text(
            "No Results Found",
            style: TextStyle(color: textColor),
          ),
          content: Text(
            "We couldn't find any location matching your search. Please try a different query.",
            style: TextStyle(color: textColor),
          ),
          actions: [
            TextButton(
              child: Text("OK", style: TextStyle(color: textColor)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Location'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search for a location...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
              onChanged: (value) {
                // Trigger the _filterLocations function whenever the text changes
                _filterLocations();
              },
            ),
            SizedBox(height: 16),
            // Show loading indicator if data is being fetched
            if (_isLoading)
              Center(
                child: CircularProgressIndicator(
                  color: const Color.fromARGB(255, 159, 118, 249),
                ),
              )
            else
              // Location List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredLocations.length,
                  itemBuilder: (context, index) {
                    final location = filteredLocations[index];
                    return ListTile(
                      title: Text(location['name']!),
                      subtitle: Text(
                        location['address']!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                      ),
                      onTap: () {
                        Navigator.pop(context, location['name']);
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
