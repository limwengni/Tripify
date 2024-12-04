import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_invite_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/views/itinerary_invitations_page.dart';
import 'package:tripify/views/itinerary_detail_page.dart';

class ItineraryPage extends StatelessWidget {
  // Sample list of itineraries
  final List<Itinerary> itineraries = [
    Itinerary(
      id: '1',
      name: 'Beach Vacation',
      startDate: DateTime(2024, 12, 10),
      endDate: DateTime(2024, 12, 14),
      invites: [
        ItineraryInvite(
            userId: 'user1',
            role: 'Member',
            inviteDate: DateTime(2024, 11, 30),
            status: InviteStatus.accepted),
        ItineraryInvite(
            userId: 'user2',
            role: 'Organizer',
            inviteDate: DateTime(2024, 11, 29),
            status: InviteStatus.pending),
      ],
      members: [],
      dailyItineraries: [
        DayItinerary(
          dayNumber: 1,
          locations: [
            ItineraryLocation(
                latitude: 1.034, longitude: 2.345, name: 'Beach A'),
            ItineraryLocation(
                latitude: 1.234, longitude: 2.346, name: 'Beach B'),
          ],
        ),
        DayItinerary(
          dayNumber: 2,
          locations: [
            ItineraryLocation(
                latitude: 12.35, longitude: 2.347, name: 'Restaurant X'),
          ],
        ),
        // More days...
      ],
      createdAt: DateTime(2024, 11, 30),
      updatedAt: DateTime(2024, 12, 1),
    ),
    // More itineraries...
  ];

  // Helper function to calculate the duration
  String getDuration(DateTime startDate, DateTime endDate) {
    final difference = endDate.difference(startDate).inDays;
    final days = difference;
    final nights = days > 0 ? days - 1 : 0;

    return '$days D $nights N';
  }

  // Helper function to format the date range (startDate - endDate)
  String formatDateRange(DateTime startDate, DateTime endDate) {
    final DateFormat formatter = DateFormat('d MMM yyyy');

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
      body: Column(
        children: [
          // Invitations button placed at the right side
          Padding(
            padding: const EdgeInsets.all(10),
            child: Align(
              alignment: Alignment.topRight,
              child: GestureDetector(
                onTap: () {
                  // Navigate to the InvitationsPage
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => InvitationsPage()),
                  );
                },
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
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
                        'Invites (${getPendingInvites(
                          itineraries
                              .expand((itinerary) => itinerary.invites ?? [])
                              .whereType<ItineraryInvite>()
                              .toList(),
                        )})',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // List of itineraries
          Expanded(
            child: ListView.builder(
              itemCount: itineraries.length,
              itemBuilder: (context, index) {
                final itinerary = itineraries[index];
                return Card(
                  margin: const EdgeInsets.all(10),
                  elevation: 5,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(15),
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
                          '(${getDuration(itinerary.startDate, itinerary.endDate!)})',
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
                          '${formatDateRange(itinerary.startDate, itinerary.endDate!)}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
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
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to add new itinerary page (you can create this page)
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        heroTag: null,
      ),
    );
  }
}
