import 'package:flutter/material.dart';
import 'package:tripify/models/itinerary_invite_model.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';  // If necessary

class InvitationsPage extends StatelessWidget {
  // Sample list of invitations
  final List<ItineraryInvite> invites = [
    ItineraryInvite(
      userId: 'user1',
      role: 'Member',
      inviteDate: DateTime(2024, 11, 30),
      status: InviteStatus.accepted,
    ),
    ItineraryInvite(
      userId: 'user2',
      role: 'Organizer',
      inviteDate: DateTime(2024, 11, 29),
      status: InviteStatus.pending,
    ),
    // Add more invites here
  ];

  // Function to handle acceptance of the invite
  void acceptInvite(ItineraryInvite invite) {
    // Handle the invite acceptance logic
    print('Accepted invite from: ${invite.userId}');
    // You can also update the status in the backend, for example
  }

  // Function to handle rejection of the invite
  void rejectInvite(ItineraryInvite invite) {
    // Handle the invite rejection logic
    print('Rejected invite from: ${invite.userId}');
    // You can also update the status in the backend, for example
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Invitations'),
      ),
      body: ListView.builder(
        itemCount: invites.length,
        itemBuilder: (context, index) {
          final invite = invites[index];
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
                      'Invite from: ${invite.userId} (${invite.role})',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Status: ${invite.status}'),
                  if (invite.status == InviteStatus.pending) 
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => acceptInvite(invite),
                          child: const Text('Accept', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 159, 118, 249)),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => rejectInvite(invite),
                          child: const Text('Reject', style: TextStyle(color: Colors.white)),
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
