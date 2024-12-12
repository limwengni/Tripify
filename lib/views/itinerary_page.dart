import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_member_model.dart';
import 'package:tripify/models/itinerary_invite_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/views/itinerary_invitations_page.dart';
import 'package:tripify/views/add_itinerary_page.dart';
import 'package:tripify/views/itinerary_detail_page.dart';
import 'package:tripify/view_models/itinerary_provider.dart';
import 'package:tripify/views/manage_members_page.dart';

class ItineraryPage extends StatefulWidget {
  const ItineraryPage({Key? key}) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  List<Itinerary> itineraries = [];
  bool isLoading = true;
  bool _isOwner = false;
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  int pendingInvitesCount = 0;

  @override
  void initState() {
    super.initState();
    fetchUserItineraries(currentUserId);
    _fetchPendingInvitesCount(currentUserId).then((count) {
      setState(() {
        pendingInvitesCount = count;
      });
    });
  }

  Future<void> _refreshData() async {
    fetchUserItineraries(currentUserId);
    int count = await _fetchPendingInvitesCount(currentUserId);
    setState(() {
      pendingInvitesCount = count;
    });
  }

  Future<int> _fetchPendingInvitesCount(String userId) async {
    try {
      final invitesQuerySnapshot = await FirebaseFirestore.instance
          .collection('ItineraryInvite')
          .where('user_id', isEqualTo: userId)
          .where('status', isEqualTo: 'pending')
          .get();

      return invitesQuerySnapshot.docs.length;
    } catch (e) {
      print("Error fetching pending invites count: $e");
      return 0;
    }
  }

  Future<void> fetchUserItineraries(String userId) async {
    ItineraryProvider provider = ItineraryProvider();
    List<Map<String, dynamic>> fetchedItineraries =
        await provider.getUserItineraries(userId);

    print("Fetched itineraries: $fetchedItineraries");

    if (fetchedItineraries.isNotEmpty) {
      List<Itinerary> itinerariesList = [];

      // Convert raw data to `Itinerary` objects
      for (var data in fetchedItineraries) {
        // Create Itinerary object
        Itinerary itinerary = Itinerary(
          id: data['id'], // Correct the doc_id to id
          name: data['name'],
          startDate: (data['start_date'] is Timestamp)
              ? (data['start_date'] as Timestamp).toDate()
              : DateTime.parse(data['start_date'] as String),
          numberOfDays: data['number_of_days'],
          dailyItineraryIds: [], // Update if needed
          createdAt: (data['created_at'] is Timestamp)
              ? (data['created_at'] as Timestamp).toDate()
              : DateTime.parse(data['created_at']),
          updatedAt: (data['updated_at'] is Timestamp)
              ? (data['updated_at'] as Timestamp).toDate()
              : (data['updated_at'] != null
                  ? DateTime.parse(data['updated_at'])
                  : null),
        );

        // Now, fetch members of this itinerary to check if the current user is an owner
        List<ItineraryMember> members =
            await provider.getItineraryMembers(itinerary.id);

        // Check if the current user is the owner of the itinerary
        for (var member in members) {
          if (member.userId == userId && member.role == 'Owner') {
            itinerary.isOwner =
                true; // Set the isOwner flag if the user is the owner
            break; // No need to continue if we found the owner
          }
        }

        // Add the itinerary to the list
        itinerariesList.add(itinerary);
      }

      for (var itinerary in itinerariesList) {
        print("Itinerary ${itinerary.name} isOwner: ${itinerary.isOwner}");
      }

      setState(() {
        itineraries = itinerariesList; // Update the UI with the itineraries
        isLoading = false; // Set loading to false once data is loaded
      });

      for (var itinerary in itinerariesList) {
        print("Itinerary ${itinerary.name} isOwner: ${itinerary.isOwner}");
      }
    } else {
      setState(() {
        isLoading =
            false; // Set loading to false if no itineraries were fetched
      });
    }
  }

  Future<void> copyItinerary(
      String originalItineraryId,
      String newItineraryName,
      DateTime newStartDate,
      int newNumberOfDays) async {
    try {
      // Fetch original itinerary data
      var originalItinerarySnapshot = await FirebaseFirestore.instance
          .collection('Itinerary')
          .doc(originalItineraryId)
          .get();

      if (!originalItinerarySnapshot.exists) {
        throw Exception("Original itinerary not found");
      }

      String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

      if (userId.isEmpty) {
        throw Exception("User is not logged in");
      }

      int originalNumberOfDays =
          originalItinerarySnapshot.data()?['numberOfDays'] ?? 0;

      if (newNumberOfDays < 1) {
        newNumberOfDays = 1;
      }

      // Create a new itinerary with the current timestamp as created_at
      var newItinerary = Itinerary(
        id: '',
        name: newItineraryName,
        numberOfDays: newNumberOfDays,
        startDate: newStartDate,
        createdAt: DateTime.now(), // New created_at timestamp
      );

      // Save the new itinerary to Firestore
      var newItineraryRef = await FirebaseFirestore.instance
          .collection('Itinerary')
          .add(newItinerary.toMap());

      await FirebaseFirestore.instance.collection('ItineraryMember').add({
        'itinerary_id': newItineraryRef.id,
        'user_id': userId,
        'role': 'Owner',
        'joined_date': DateTime.now(),
      });

      // Fetch DayItineraries for the original itinerary
      var dayItinerarySnapshot = await FirebaseFirestore.instance
          .collection('DayItinerary')
          .where('itinerary_id', isEqualTo: originalItineraryId)
          .get();

      List<DayItinerary> newDayItineraries = [];

      // Loop through the original DayItineraries and copy data
      int copiedDays = 0;
      for (var dayDoc in dayItinerarySnapshot.docs) {
        if (copiedDays >= newNumberOfDays) break;

        var dayData = dayDoc.data();
        int dayNumber = dayData['day_number'];
        List<String> originalLocationIds =
            List<String>.from(dayData['location_ids'] ?? []);

        // Create a list to store new location IDs
        List<String> newLocationIds = [];

        // Fetch the original ItineraryLocation data based on originalLocationIds
        var locationSnapshot = await FirebaseFirestore.instance
            .collection('ItineraryLocation')
            .where(FieldPath.documentId, whereIn: originalLocationIds)
            .get();

        for (var locationDoc in locationSnapshot.docs) {
          var locationData = locationDoc.data();
          // Create new ItineraryLocation with the same fields (latitude, longitude, name, etc.)
          var newLocationRef = await FirebaseFirestore.instance
              .collection('ItineraryLocation')
              .add({
            'name': locationData['name'],
            'latitude': locationData['latitude'],
            'longitude': locationData['longitude'],
          });

          // Add new location ID to the list
          newLocationIds.add(newLocationRef.id);
        }

        // Create a new DayItinerary with the new location IDs
        DayItinerary newDayItinerary = DayItinerary(
          id: '',
          itineraryId: newItineraryRef.id,
          dayNumber: dayNumber,
          locationIds: newLocationIds,
          createdAt: DateTime.now(),
          updatedAt: null,
        );

        // Save the new DayItinerary in Firestore
        await FirebaseFirestore.instance
            .collection('DayItinerary')
            .add(newDayItinerary.toMap());

        newDayItineraries.add(newDayItinerary);

        copiedDays++;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Itinerary copied successfully!'),
          backgroundColor: Color(0xFF9F76F9),
        ),
      );
    } catch (e) {
      print("Error copying itinerary: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to copy itinerary.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showCopyItineraryDialog(
      BuildContext context, String originalItineraryId) {
    TextEditingController _itineraryNameController = TextEditingController();
    TextEditingController _numberOfDaysController = TextEditingController();
    DateTime? startDate;
    DateTime? endDate;
    int numberOfDays = 1;

    // Function to pick the start date
    void _pickStartDate() async {
      final selectedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100),
      );
      if (selectedDate != null) {
        startDate = selectedDate;
      }
    }

    // Show dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Copy Itinerary"),
          content: SingleChildScrollView(
            child: Form(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Itinerary Name Field
                  TextFormField(
                    controller: _itineraryNameController,
                    decoration: InputDecoration(labelText: 'Itinerary Name'),
                  ),
                  SizedBox(height: 20),

                  // Number of Days Field
                  TextFormField(
                    controller: _numberOfDaysController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: 'Number of Days'),
                    onChanged: (value) {
                      int? days = int.tryParse(value);
                      if (days != null && days > 0) {
                        numberOfDays = days;
                      }
                    },
                  ),
                  SizedBox(height: 20),

                  // Start Date Picker
                  StatefulBuilder(
                    builder: (BuildContext context, setState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (selectedDate != null) {
                                setState(() {
                                  startDate = selectedDate;
                                  endDate = startDate!
                                      .add(Duration(days: numberOfDays - 1));
                                });
                              }
                            },
                            child: Text(
                              startDate == null
                                  ? 'Select Start Date'
                                  : DateFormat('dd MMM yyyy')
                                      .format(startDate!),
                            ),
                          ),
                          if (startDate != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 16.0),
                              child: Text(
                                'End Date: ${DateFormat('dd MMM yyyy').format(endDate!)}',
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                String newItineraryName = _itineraryNameController.text;
                if (newItineraryName.isEmpty || startDate == null) {
                  // Show a snackbar or alert if the user didn't enter required fields
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Please fill out all fields'),
                    backgroundColor: Colors.red,
                  ));
                  return;
                }

                // Call copyItinerary with the entered values
                copyItinerary(originalItineraryId, newItineraryName, startDate!,
                    numberOfDays);

                // Close the dialog after copying
                Navigator.of(context).pop();
              },
              child: Text("Copy"),
            ),
          ],
        );
      },
    );
  }

  Future<bool> showDeleteConfirmationDialog(BuildContext context) async {
    // Show the confirmation dialog and expect a boolean response
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the dialog by tapping outside
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Are you sure?'),
          content: Text(
              'Do you really want to delete this itinerary? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // User clicked "No" - return false
              },
              child: Text('No'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(true); // User clicked "Yes" - return true
              },
              child: Text('Yes'),
            ),
          ],
        );
      },
    );

    // Return the result, or default to false if the dialog is dismissed
    return result ?? false;
  }

  Future<void> deleteItinerary(String itineraryId, bool confirmed) async {
    try {
      if (confirmed) {
        // First, fetch all DayItinerary documents related to the itinerary
        var dayItinerarySnapshot = await FirebaseFirestore.instance
            .collection('DayItinerary')
            .where('itinerary_id', isEqualTo: itineraryId)
            .get();

        List<String> locationIds = [];
        for (var dayDoc in dayItinerarySnapshot.docs) {
          var dayData = dayDoc.data();
          locationIds.addAll(List<String>.from(dayData['location_ids'] ?? []));
        }

        var locationSnapshot = await FirebaseFirestore.instance
            .collection('ItineraryLocation')
            .where(FieldPath.documentId, whereIn: locationIds)
            .get();

        for (var locationDoc in locationSnapshot.docs) {
          await locationDoc.reference.delete(); // Delete the location
        }

        await FirebaseFirestore.instance
            .collection('Itinerary')
            .doc(itineraryId)
            .delete();

        for (var dayDoc in dayItinerarySnapshot.docs) {
          await dayDoc.reference.delete(); // Delete each DayItinerary
        }

        // Also delete related ItineraryMember (if needed)
        var memberSnapshot = await FirebaseFirestore.instance
            .collection('ItineraryMember')
            .where('itinerary_id', isEqualTo: itineraryId)
            .get();

        for (var memberDoc in memberSnapshot.docs) {
          await memberDoc.reference.delete(); // Delete each ItineraryMember
        }

        var inviteSnapshot = await FirebaseFirestore.instance
            .collection('ItineraryInvite')
            .where('itinerary_id', isEqualTo: itineraryId)
            .get();

        for (var inviteDoc in inviteSnapshot.docs) {
          await inviteDoc.reference.delete(); // Delete each ItineraryInvite
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Itinerary deleted successfully!'),
            backgroundColor: Color(0xFF9F76F9),
          ),
        );
      } else {
        // Do nothing if the user cancels
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Itinerary deletion canceled.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print("Error deleting itinerary: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete itinerary.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  DateTime calculateEndDate(DateTime startDate, int numberOfDays) {
    return startDate.add(Duration(days: numberOfDays - 1));
  }

  // Helper function to calculate the duration
  String getDuration(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    final days = difference;
    final nights = days > 0 ? days - 1 : 0;

    return '$days D $nights N';
  }

  // Helper function to format the date range (startDate - endDate)
  String formatDateRange(DateTime startDate, DateTime endDate) {
    final DateFormat formatter = DateFormat('dd MMM yyyy');

    print('end date: $endDate');

    return '${formatter.format(startDate)} - ${formatter.format(endDate)}';
  }

  int getPendingInvites(List<ItineraryInvite> invites) {
    return invites
        .where((invite) => invite.status == InviteStatus.pending)
        .toList()
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.white,
          backgroundColor: const Color.fromARGB(255, 159, 118, 249),
          child: Column(
            children: [
              // Invitations button placed at the right side
              Padding(
                padding: const EdgeInsets.all(15),
                child: Align(
                  alignment: Alignment.topRight,
                  child: GestureDetector(
                    onTap: () {
                      // Navigate to the InvitationsPage
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => InvitationsPage()),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 15),
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 159, 118, 249),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.mail,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Invites ($pendingInvitesCount)',
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // List of itineraries
              isLoading
                  ? Expanded(
                      child: Center(
                        child: CircularProgressIndicator(
                          color: const Color.fromARGB(255, 159, 118, 249),
                        ),
                      ),
                    )
                  : itineraries.isNotEmpty
                      ? Expanded(
                          child: ListView.builder(
                            itemCount: itineraries.length,
                            itemBuilder: (context, index) {
                              final itinerary = itineraries[index];
                              DateTime endDate = calculateEndDate(
                                  itinerary.startDate, itinerary.numberOfDays);

                              bool isOwner = itinerary.isOwner;

                              return Card(
                                margin: const EdgeInsets.all(10),
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.only(
                                      left: 25, top: 10, bottom: 10),
                                  title: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          itinerary.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        '(${getDuration(itinerary.startDate, endDate)})',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Show date range in format: "03 Jan - 09 Jan 2025"
                                      Text(
                                        '${formatDateRange(itinerary.startDate, endDate)}',
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ],
                                  ),
                                  trailing: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: PopupMenuButton<String>(
                                        icon: Icon(Icons.more_vert),
                                        onSelected: (value) async {
                                          // Handle the selected option here
                                          switch (value) {
                                            case 'edit':
                                              // Edit logic
                                              break;
                                            case 'delete':
                                              // Delete logic
                                              bool confirmed =
                                                  await showDeleteConfirmationDialog(
                                                      context);
                                              if (confirmed) {
                                                String itineraryId =
                                                    itinerary.id;
                                                await deleteItinerary(
                                                    itineraryId, true);
                                              } else {
                                                // The dialog was dismissed or the user clicked "No"
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  SnackBar(
                                                    content: Text(
                                                        'Itinerary deletion canceled.'),
                                                    backgroundColor:
                                                        Colors.orange,
                                                  ),
                                                );
                                              }
                                              break;
                                            case 'manage':
                                              // Manage Members logic
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ManageMembersPage(
                                                          itineraryId:
                                                              itinerary.id),
                                                ),
                                              );
                                              break;
                                            case 'copy':
                                              // Make a copy logic
                                              _showCopyItineraryDialog(
                                                  context, itinerary.id);
                                              break;
                                            default:
                                              // Handle any unexpected value if needed
                                              break;
                                          }
                                        },
                                        itemBuilder: (BuildContext context) {
                                          return <PopupMenuEntry<String>>[
                                            if (isOwner)
                                              PopupMenuItem<String>(
                                                value: 'manage',
                                                child: Text('Manage Members'),
                                              ),
                                            PopupMenuItem<String>(
                                              value: 'copy',
                                              child: Text('Make a copy'),
                                            ),
                                            if (isOwner)
                                              PopupMenuItem<String>(
                                                value: 'delete',
                                                child: Text('Delete'),
                                              ),
                                          ];
                                        },
                                      )),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ItineraryDetailPage(
                                          itinerary: itinerary,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        )
                      : Expanded(
                          child: Center(
                          child: Text("No itineraries available"),
                        )),
            ],
          )),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddItineraryPage(),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        heroTag: null,
      ),
    );
  }
}
