import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/itinerary_member_model.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_invite_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/views/itinerary_invitations_page.dart';
import 'package:tripify/views/add_itinerary_page.dart';
import 'package:tripify/views/itinerary_detail_page.dart';
import 'package:tripify/view_models/itinerary_provider.dart';
import 'package:tripify/view_models/firestore_service.dart';

class ManageMembersPage extends StatefulWidget {
  final String itineraryId;

  ManageMembersPage({required this.itineraryId});

  @override
  _ManageMembersPageState createState() => _ManageMembersPageState();
}

class _ManageMembersPageState extends State<ManageMembersPage> {
  bool isLoading = true;
  List<ItineraryMember> members = [];
  String memberUsername = '';
  TextEditingController _usernameController = TextEditingController();
  dynamic foundUser;
  FirestoreService firestoreService = FirestoreService();
  bool hasChanges = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    fetchMembers();
  }

  Future<void> fetchMembers() async {
    try {
      // Retrieve members based on the itinerary ID
      ItineraryProvider provider = ItineraryProvider();
      List<ItineraryMember> fetchedMembers =
          await provider.getItineraryMembers(widget.itineraryId);
      bool isOwner = false;

      for (var member in fetchedMembers) {
        if (member.userId == FirebaseAuth.instance.currentUser!.uid) {
          setState(() {
            isOwner = member.role == 'Owner';
          });
          print("member username: ${member.username}");
          print("member id: ${member.userId}");
          break;
        }
      }

      print("owner: $isOwner");

      setState(() {
        members = fetchedMembers;
        isLoading = false;
        _isOwner = isOwner;
      });
    } catch (e) {
      print("Error fetching members: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _searchUser(String username) async {
    await firestoreService.searchUser(username);

    setState(() {
      foundUser = firestoreService.userModel;
    });
  }

  void _addMember() {
    if (foundUser != null) {
      setState(() {
        if (!members.any((member) => member.username == foundUser?.username)) {
          members.add(ItineraryMember(
              userId: foundUser?.uid ?? '',
              username: foundUser?.username ?? '',
              profilePic: foundUser?.profilePic ?? '',
              role: 'Member',
              joinedDate: DateTime.now(),
              isTemporary: true));
          hasChanges = true;
        }
        foundUser = null;
        memberUsername = '';
        _usernameController.clear();
        FocusScope.of(context).unfocus();
      });
    }
  }

  void _updateRole(int index, String newRole) async {
    setState(() {
      members[index].role = newRole;
      hasChanges = true;
    });
  }

  void _removeMember(int index) async {
    // Get the member to be removed
    ItineraryMember memberToRemove = members[index];

    // Show confirmation dialog before removing member
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Removal'),
        content: Text('Are you sure you want to remove this member?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Remove'),
            onPressed: () async {
              // Close the dialog
              Navigator.of(context).pop();

              if (memberToRemove.isTemporary) {
                // Remove from the local list for temporary members
                setState(() {
                  members.removeAt(index);
                  hasChanges = true;
                });

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Temporary member removed successfully!'),
                  backgroundColor: Color(0xFF9F76F9),
                ));
              } else {
                // Handle database removal for permanent members
                WriteBatch batch = FirebaseFirestore.instance.batch();

                try {
                  // Query for the member document to delete
                  QuerySnapshot memberSnapshot = await FirebaseFirestore
                      .instance
                      .collection('ItineraryMember')
                      .where('itinerary_id', isEqualTo: widget.itineraryId)
                      .where('user_id', isEqualTo: memberToRemove.userId)
                      .get();

                  if (memberSnapshot.docs.isNotEmpty) {
                    // Get the first document (there should only be one matching)
                    DocumentSnapshot memberDoc = memberSnapshot.docs.first;
                    DocumentReference memberRef = memberDoc.reference;

                    batch.delete(memberRef);

                    await batch.commit();

                    // Remove from local members list
                    setState(() {
                      members.removeAt(index);
                      hasChanges = true;
                    });

                    // Show success message
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Member removed successfully!'),
                      backgroundColor: Color(0xFF9F76F9),
                    ));
                  }
                } catch (e) {
                  // Handle any errors
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('Failed to remove member.'),
                    backgroundColor: Colors.red,
                  ));
                }
              }
            },
          ),
        ],
      ),
    );
  }

  void _transferOwnership(int index) async {
    // Get the member to be transferred to owner
    ItineraryMember newOwner = members[index];

    // Check if there are other permanent members aside from the current owner
    int permanentMemberCount = members
        .where(
            (member) => member.isTemporary == false && member.role != 'Owner')
        .length;

    if (permanentMemberCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'Cannot transfer ownership. No other permanent members exist.'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    // Show confirmation dialog before transferring ownership
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transfer Ownership'),
        content:
            Text('Are you sure you want to transfer ownership to this member?'),
        actions: <Widget>[
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Transfer'),
            onPressed: () async {
              try {
                // Initialize WriteBatch
                WriteBatch batch = FirebaseFirestore.instance.batch();

                // Get the current owner document reference
                QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                    .collection('ItineraryMember')
                    .where('itinerary_id', isEqualTo: widget.itineraryId)
                    .where('role', isEqualTo: 'Owner')
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  // Correct the type for DocumentReference
                  DocumentReference<Map<String, dynamic>> currentOwnerRef =
                      querySnapshot.docs.first.reference
                          as DocumentReference<Map<String, dynamic>>;

                  // Update the current owner's role to 'Member'
                  batch.update(currentOwnerRef, {'role': 'Member'});
                }

                // Get the new owner's document reference
                querySnapshot = await FirebaseFirestore.instance
                    .collection('ItineraryMember')
                    .where('itinerary_id', isEqualTo: widget.itineraryId)
                    .where('user_id', isEqualTo: newOwner.userId)
                    .limit(1)
                    .get();

                if (querySnapshot.docs.isNotEmpty) {
                  // Correct the type for DocumentReference
                  DocumentReference<Map<String, dynamic>> newOwnerRef =
                      querySnapshot.docs.first.reference
                          as DocumentReference<Map<String, dynamic>>;

                  // Update the new owner's role to 'Owner'
                  batch.update(newOwnerRef, {'role': 'Owner'});
                }

                // Commit the batch
                await batch.commit();

                // Update local list
                setState(() {
                  members.firstWhere((member) => member.role == 'Owner').role =
                      'Member';
                  members[index].role = 'Owner';
                  hasChanges = true;
                });

                // Close the dialog
                Navigator.of(context).pop();

                // Show success message
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Ownership transferred successfully!'),
                  backgroundColor: Color(0xFF9F76F9),
                ));
              } catch (e) {
                // Handle any errors
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Failed to transfer ownership.'),
                  backgroundColor: Colors.red,
                ));
              }
            },
          ),
        ],
      ),
    );
  }

  void _saveChanges() async {
    setState(() {
      hasChanges = false;
    });

    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Saving changes...')));

    try {
      // Initialize WriteBatch for atomic operations
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Loop through all the members and check if they have an invitation
      for (var member in members) {
        // Check if member has an invitation
        var inviteQuery = await FirebaseFirestore.instance
            .collection('ItineraryInvite')
            .where('itinerary_id', isEqualTo: widget.itineraryId)
            .where('user_id', isEqualTo: member.userId)
            .where('status', isEqualTo: 'pending')
            .limit(1)
            .get();

        print('Query results: ${inviteQuery.docs.length}');

        if (inviteQuery.docs.isEmpty) {
          // No invitation exists, so create a new one
          DocumentReference newInviteRef = FirebaseFirestore.instance
              .collection('ItineraryInvite')
              .doc(); // Automatically generate a new document ID

          // Add the new invitation record
          batch.set(newInviteRef, {
            'itinerary_id': widget.itineraryId,
            'user_id': member.userId,
            'role': member.role,
            'status': 'pending',
            'created_at': DateTime.now(),
          });
        }
      }

      // Commit the batch to Firestore
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Changes saved successfully!'),
        backgroundColor: Color(0xFF9F76F9),
      ));
    } catch (e) {
      // Handle errors if the batch commit fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save changes.'),
        backgroundColor: Colors.red,
      ));
      setState(() {
        hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Manage Members'),
        ),
        body: Column(children: [
          // Search field
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 8.0),
            child: TextFormField(
              controller: _usernameController,
              decoration: InputDecoration(
                  labelText: 'Member Username', border: OutlineInputBorder()),
              onChanged: (value) {
                setState(() {
                  memberUsername = value;
                });
                _searchUser(value); // Search for the user as they type
              },
            ),
          ),
          // Show found user
          if (foundUser != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _addMember,
                  child: Container(
                    padding:
                        EdgeInsets.only(left: 18, right: 18, top: 8, bottom: 8),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(foundUser?.profilePic ?? ''),
                          radius: 26,
                        ),
                        SizedBox(width: 16),
                        Text(
                          foundUser?.username ?? 'Username not found',
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          isLoading
              ? Center(
                  child: CircularProgressIndicator(
                  color: Color(0xFF9F76F9),
                ))
              : Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];

                      return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: 8), // Padding for each member
                          child: ListTile(
                            leading: member.profilePic!.isNotEmpty
                                ? CircleAvatar(
                                    backgroundImage:
                                        NetworkImage(member.profilePic!),
                                    radius: 26,
                                  )
                                : Icon(Icons.account_circle),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Username
                                Text(
                                  member.username!,
                                  style: TextStyle(fontSize: 18),
                                ),
                                // Show the role text or dropdown depending on the role
                                member.role == 'Owner'
                                    ? Padding(
                                        padding: EdgeInsets.only(right: 20),
                                        child: Text(
                                          'Owner',
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ))
                                    : DropdownButton<String>(
                                        value: member.role,
                                        icon: Icon(Icons.more_vert),
                                        onChanged: (String? value) {
                                          if (value == 'Transfer Ownership') {
                                            _transferOwnership(index);
                                          } else if (value == 'Remove Access') {
                                            _removeMember(index);
                                          } else if (value == 'Member') {
                                            _updateRole(index, 'Member');
                                          }
                                        },
                                        items: [
                                          DropdownMenuItem<String>(
                                            value: 'Member',
                                            child: Text('Member'),
                                          ),
                                          if (_isOwner)
                                            DropdownMenuItem<String>(
                                              value: 'Transfer Ownership',
                                              child: Text('Transfer Ownership'),
                                            ),
                                          if (_isOwner)
                                            DropdownMenuItem<String>(
                                              value: 'Remove Access',
                                              child: Text('Remove Access'),
                                            ),
                                        ],
                                      ),
                              ],
                            ),
                          ));
                    },
                  ),
                ),
          if (hasChanges)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed: _saveChanges,
                child: Text(
                  'Save Changes',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF9F76F9)),
              ),
            ),
        ]));
  }
}
