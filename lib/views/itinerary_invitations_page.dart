import 'package:flutter/material.dart';
import 'package:tripify/models/itinerary_invite_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_location_model.dart'; // If necessary

class InvitationsPage extends StatefulWidget {
  @override
  _InvitationsPageState createState() => _InvitationsPageState();
}

class _InvitationsPageState extends State<InvitationsPage> {
  List<ItineraryInvite> pendingInvites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPendingInvites();
  }

  Future<void> _refreshData() async {
    _fetchPendingInvites();
  }

  // Fetch invitations from Firestore
  Future<void> _fetchPendingInvites() async {
    try {
      // Get the current user ID
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      // Fetch pending invitations where user_id matches the current user's UID
      var inviteSnapshot = await FirebaseFirestore.instance
          .collection('ItineraryInvite')
          .where('user_id', isEqualTo: currentUserId)
          .where('status', isEqualTo: 'pending')
          .get();

      // Map Firestore data to ItineraryInvite models and include document IDs
      List<ItineraryInvite> fetchedInvites = inviteSnapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return ItineraryInvite.fromMap(
            data, doc.id); // Pass doc.id to the factory method
      }).toList();

      for (var invite in fetchedInvites) {
        var itinerarySnapshot = await FirebaseFirestore.instance
            .collection('Itinerary')
            .doc(invite.itineraryId)
            .get();

        if (itinerarySnapshot.exists) {
          // Update the invite's username with the fetched username
          invite.itineraryName =
              itinerarySnapshot.data()?['name'] ?? 'Unknown Itinerary';
        } else {
          invite.itineraryName = 'Unknown Itinerary';
        }
      }

      // Update the state with fetched data
      setState(() {
        pendingInvites = fetchedInvites;
        isLoading = false;
      });

      await _refreshData();
    } catch (e) {
      print('Error fetching pending invites: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Function to handle acceptance of the invite
  void acceptInvite(ItineraryInvite invite) async {
    try {
      await FirebaseFirestore.instance
          .collection('ItineraryInvite')
          .doc(invite.docId)
          .update({'status': 'accepted'});

      await FirebaseFirestore.instance.collection('ItineraryMember').add({
        'itinerary_id': invite.itineraryId,
        'joined_date': DateTime.now(),
        'role': 'Member',
        'user_id': FirebaseAuth.instance.currentUser!.uid,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite Accepted!'),
          backgroundColor: Color(0xFF9F76F9),
        ),
      );

      await _refreshData();
    } catch (e) {
      print('Error accepting invite: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to accept invite!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Function to handle rejection of the invite
  void rejectInvite(ItineraryInvite invite) async {
    try {
      await FirebaseFirestore.instance
          .collection('ItineraryInvite')
          .doc(invite.docId)
          .update({'status': 'rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invite Rejected!'),
          backgroundColor: Color(0xFF9F76F9),
        ),
      );
    } catch (e) {
      print('Error rejecting invite: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to reject invite!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Invitations'),
        ),
        body: RefreshIndicator(
          onRefresh: _refreshData,
          color: Colors.white,
          backgroundColor: const Color.fromARGB(255, 159, 118, 249),
          child: isLoading
              ? Center(
                  child: CircularProgressIndicator(
                      color: Color(0xFF9F76F9))) // Show loading spinner
              : (pendingInvites.isEmpty
                  ? Center(child: Text('No pending invites'))
                  : ListView.builder(
                      itemCount: pendingInvites.length,
                      itemBuilder: (context, index) {
                        final invite = pendingInvites[index];
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
                                      "You've been invited to ${invite.itineraryName} as ${invite.role.toLowerCase()}",
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
                                    if (invite.status == InviteStatus.pending)
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Text(
                                            'You can accept or reject this invitation.',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () =>
                                                    acceptInvite(invite),
                                                child: const Text('Accept',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        const Color.fromARGB(
                                                            255,
                                                            159,
                                                            118,
                                                            249)),
                                              ),
                                              const SizedBox(width: 10),
                                              ElevatedButton(
                                                onPressed: () =>
                                                    rejectInvite(invite),
                                                child: const Text('Reject',
                                                    style: TextStyle(
                                                        color: Colors.white)),
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Colors.red),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                  ]),
                            ));
                      },
                    )),
        ));
  }
}
