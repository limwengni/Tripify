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
      // Convert raw data to `Itinerary` objects
      setState(() {
        itineraries = fetchedItineraries.map((data) {
          return Itinerary(
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
        }).toList();
        isLoading = false;
      });

      for (var itinerary in itineraries) {
        List<ItineraryMember> fetchedMembers =
            await provider.getItineraryMembers(itinerary.id);

        bool isOwner = false;

        for (var member in fetchedMembers) {
          if (member.userId == currentUserId) {
            setState(() {
              isOwner = member.role == 'Owner';
            });
            print("member username: ${member.username}");
            break;
          }
        }

        print("owner: $isOwner");

        setState(() {
          _isOwner = isOwner;
        });
      }
    } else {
      setState(() {
        isLoading = false;
      });
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
          onRefresh: _refreshData, // Trigger the refresh logic
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
                  : Expanded(
                      child: ListView.builder(
                        itemCount: itineraries.length,
                        itemBuilder: (context, index) {
                          final itinerary = itineraries[index];
                          DateTime endDate = calculateEndDate(
                              itinerary.startDate, itinerary.numberOfDays);

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
                                crossAxisAlignment: CrossAxisAlignment.start,
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
                                    onSelected: (value) {
                                      // Handle the selected option here
                                      switch (value) {
                                        case 'edit':
                                          // Edit logic
                                          break;
                                        case 'delete':
                                          // Delete logic
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
                                          break;
                                        default:
                                          // Handle any unexpected value if needed
                                          break;
                                      }
                                    },
                                    itemBuilder: (BuildContext context) {
                                      return <PopupMenuEntry<String>>[
                                        if (_isOwner)
                                          PopupMenuItem<String>(
                                            value: 'manage',
                                            child: Text('Manage Members'),
                                          ),
                                        // if (_isOwner)
                                        //   PopupMenuItem<String>(
                                        //     value: 'edit',
                                        //     child: Text('Edit'),
                                        //   ),
                                        PopupMenuItem<String>(
                                          value: 'copy',
                                          child: Text('Make a copy'),
                                        ),
                                        if (_isOwner)
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
                                    builder: (context) => ItineraryDetailPage(
                                      itinerary: itinerary,
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
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
