import 'package:flutter/material.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/views/add_location_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ViewMorePage extends StatefulWidget {
  final String itineraryId;
  final int dayNumber;

  ViewMorePage({required this.itineraryId, required this.dayNumber});

  @override
  _ViewMorePageState createState() => _ViewMorePageState();
}

class _ViewMorePageState extends State<ViewMorePage> {
  bool _hasChanges = false;
  late List<ItineraryLocation> locations;

  @override
  void initState() {
    super.initState();
    locations = [];
  }

  void refreshLocations() {
    setState(() {
      _fetchLocationsForDay(widget.itineraryId,
            widget.dayNumber);
    });
  }

  @override
  Widget build(BuildContext context) {
    List<String> locationIds = [];

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Itinerary Places - Day ${widget.dayNumber}"),
      ),
      body: FutureBuilder<List<ItineraryLocation>>(
        future: _fetchLocationsForDay(widget.itineraryId,
            widget.dayNumber), // Fetch locations for the specific day
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: CircularProgressIndicator(color: Color(0xFF9F76F9)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            // If no data, show "Add Places" button
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ElevatedButton(
                  onPressed: () {
                    _addMorePlaces(widget
                        .dayNumber); // Pass the day number to AddLocationPage
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child:
                      Text("Add Places", style: TextStyle(color: Colors.white)),
                ),
              ),
            );
          } else {
            List<ItineraryLocation> locations = snapshot.data!;
            print("length: ${locations.length}");

            return Column(children: [
              Expanded(
                child: ReorderableListView(
                  onReorder: (oldIndex, newIndex) {
                    onReorder(locations, oldIndex, newIndex);
                  },
                  children: List.generate(locations.length, (index) {
                    final location = locations[index];
                    return Card(
                      key: ValueKey(index),
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        key: ValueKey(location
                            .id), // Ensure each ListTile is uniquely identifiable
                        tileColor: Colors.white,
                        title: Text(location.name),
                        onTap: () {
                          // Optional: Navigate to a detailed page for the location
                        },
                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min, // Align icons to the right
                          children: [
                            ReorderableDragStartListener(
                              index: index,
                              child: const Icon(Icons.drag_handle),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                print(
                                    "Deleting location with ID: ${location.id}");

                                // Show confirmation dialog for deletion
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Confirm Deletion'),
                                      content: Text(
                                          'Are you sure you want to delete this location?'),
                                      actions: <Widget>[
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close dialog
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close dialog
                                            _deleteLocation(location
                                                .id); // Proceed with deletion
                                          },
                                          child: Text('Delete'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ),
              // if (_hasChanges) // Show the save button only if there are changes
              //   Padding(
              //     padding: const EdgeInsets.all(16.0),
              //     child: ElevatedButton(
              //       onPressed: () {
              //         // Show confirmation dialog
              //         showDialog(
              //           context: context,
              //           builder: (BuildContext context) {
              //             return AlertDialog(
              //               title: Text('Confirm Save Changes'),
              //               content: Text(
              //                   'Are you sure you want to save the changes?'),
              //               actions: <Widget>[
              //                 // Cancel button: closes the dialog without saving
              //                 TextButton(
              //                   onPressed: () {
              //                     Navigator.of(context)
              //                         .pop(); // Close the dialog
              //                   },
              //                   child: Text('Cancel'),
              //                 ),
              //                 // Confirm button: calls _updateLocationOrderInFirestore to save
              //                 TextButton(
              //                   onPressed: () {
              //                     Navigator.of(context)
              //                         .pop(); // Close the dialog
              //                     _updateLocationOrderInFirestore(); // Proceed with saving changes
              //                   },
              //                   child: Text('Save'),
              //                 ),
              //               ],
              //             );
              //           },
              //         );
              //       },
              //       style: ElevatedButton.styleFrom(
              //           backgroundColor: Color(0xFF9F76F9)),
              //       child: Text(
              //         "Save Changes",
              //         style: TextStyle(color: Colors.white),
              //       ),
              //     ),
              //   ),
            ]);
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addMorePlaces(
              widget.dayNumber); // Pass the day number to AddLocationPage
        },
        backgroundColor: Colors.blue,
        child: Icon(Icons.add, color: Colors.white), // Add icon to the FAB
      ),
    );
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
          locations.add(ItineraryLocation.fromMap(locationData, documentId));
        }
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
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLocationPage(
          itineraryId: widget.itineraryId,
          dayNumber: dayNumber,
        ),
      ),
    );

    if (result == true) {
      setState(() {});
    }
  }

  void onReorder(
      List<ItineraryLocation> locations, int oldIndex, int newIndex) {
    if (locations.isEmpty || locations.length == 1) {
      print('List is empty or has only one item. No reorder needed.');
      return;
    }

    // Ensure newIndex is within bounds of the list
    if (newIndex >= locations.length) {
      newIndex = locations.length - 1; // Set newIndex to the last valid index
    }

    // Adjust newIndex when moving down, since the list will shrink
    if (oldIndex < newIndex) {
      newIndex--;
    }

    setState(() {
      if (oldIndex < 0 ||
          oldIndex >= locations.length ||
          newIndex < 0 ||
          newIndex >= locations.length) {
        print(
            'Invalid index range during reorder: oldIndex = $oldIndex, newIndex = $newIndex');
        return; // Return early if indices are invalid
      }

      // Remove the item at oldIndex
      final item = locations
          .removeAt(oldIndex); // Use removeAt to correctly remove by index
      // Insert the item at newIndex
      locations.insert(newIndex, item);
    });

    // Extract location IDs
    List<String> locationIds = locations.map((loc) => loc.id).toList();

    // Print the location IDs for debugging
    print('Location IDs after reorder: $locationIds');

    // Update Firestore with the new location order
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateLocationOrderInFirestore(locationIds);
    });
  }

  // Method to handle deleting a location
  void _deleteLocation(String locationId) async {
    if (locationId.isEmpty) {
      print("Location ID is empty!");
      return;
    }

    try {
      // Remove the location from Firestore
      await FirebaseFirestore.instance
          .collection('ItineraryLocation')
          .doc(locationId)
          .delete();

      // Remove the location ID from DayItinerary
      var dayItinerarySnapshot = await FirebaseFirestore.instance
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: widget.itineraryId)
          .where('day_number', isEqualTo: widget.dayNumber)
          .get();

      if (dayItinerarySnapshot.docs.isNotEmpty) {
        var dayItineraryData = dayItinerarySnapshot.docs.first.data();
        List<String> locationIds =
            List<String>.from(dayItineraryData['location_ids'] ?? []);

        // Remove the location ID from the list
        locationIds.remove(locationId);

        // Update the DayItinerary with the new list
        await FirebaseFirestore.instance
            .collection('DayItinerary')
            .doc(dayItinerarySnapshot.docs.first.id)
            .update({
          'location_ids': locationIds,
        });

        // Remove the location from the UI
        setState(() {
          locations.removeWhere((location) => location.id == locationId);
        });
      }
    } catch (e) {
      print("Error deleting location: $e");
    }
  }

  // Method to update the order of locations in Firestore
  Future<void> _updateLocationOrderInFirestore(List<String> locationIds) async {
    try {
      var dayItinerarySnapshot = await FirebaseFirestore.instance
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: widget.itineraryId)
          .where('day_number', isEqualTo: widget.dayNumber)
          .get();

      if (dayItinerarySnapshot.docs.isNotEmpty) {
        var dayItineraryData = dayItinerarySnapshot.docs.first.data();
        print('DayItinerary document found: $dayItineraryData');

        if (locationIds.isEmpty) {
          print('No locations to update');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('No locations to update'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        print('Location IDs to update: $locationIds');

        // Update the location IDs in Firestore
        await FirebaseFirestore.instance
            .collection('DayItinerary')
            .doc(dayItinerarySnapshot.docs.first.id)
            .update({'location_ids': locationIds});

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location order updated successfully'),
            backgroundColor: Color(0xFF9F76F9),
          ),
        );

        refreshLocations();
      } else {
        // Show failure Snackbar if no documents found
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No DayItinerary document found for this itinerary'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("Error updating location order in Firestore: $e");

      // Show failure Snackbar in case of an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating location order'),
          backgroundColor: Colors.red, // Red for failure
        ),
      );
    }
  }
}
