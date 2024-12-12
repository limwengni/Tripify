import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/itinerary_model.dart';
import 'package:tripify/models/itinerary_member_model.dart';
import 'package:tripify/models/itinerary_invite_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';

class ItineraryProvider {
  Future<bool> createItinerary({
    required String itineraryName,
    required DateTime startDate,
    required int numberOfDays,
    required List<Map<String, String>>
        invites, // List of invitees with user_id and role
    required List<Map<String, String>> members, // Owner only for now
  }) async {
    final batch = FirebaseFirestore.instance.batch();

    final itineraryRef =
        FirebaseFirestore.instance.collection('Itinerary').doc();
    final itinerary = {
      'name': itineraryName,
      'start_date': startDate,
      'number_of_days': numberOfDays,
      'created_at': DateTime.now(),
    };

    batch.set(itineraryRef, itinerary);

    for (var member in members) {
      final memberRef =
          FirebaseFirestore.instance.collection('ItineraryMember').doc();
      final memberData = {
        'itinerary_id': itineraryRef.id,
        'user_id': member['user_id'],
        'role': member['role'],
        'joined_date': DateTime.now(),
      };

      batch.set(memberRef, memberData);
    }

    for (var invite in invites) {
      final inviteRef =
          FirebaseFirestore.instance.collection('ItineraryInvite').doc();
      final inviteData = {
        'itinerary_id': itineraryRef.id,
        'user_id': invite['user_id'],
        'role': invite['role'],
        'invite_date': DateTime.now(),
        'status': 'pending', // Default status can be 'pending'
      };

      // Add each invite document to the batch
      batch.set(inviteRef, inviteData);
    }

    try {
      // Commit the batch
      await batch.commit();
      return true;
    } catch (error) {
      print('Error creating itinerary and invites: $error');
      return false;
    }
  }

  Future<List<Map<String, dynamic>>> getUserItineraries(String userId) async {
    try {
      // First, get the itineraries where the user is a member
      QuerySnapshot memberSnapshot = await FirebaseFirestore.instance
          .collection('ItineraryMember')
          .where('user_id', isEqualTo: userId)
          .get();

      // If no members found, return an empty list
      if (memberSnapshot.docs.isEmpty) {
        return [];
      }

      // Extract itinerary IDs from the member documents
      List<String> itineraryIds = memberSnapshot.docs
          .map((doc) => doc['itinerary_id'] as String)
          .toList();

      // Now, get the details of those itineraries from the 'Itinerary' collection
      QuerySnapshot itinerarySnapshot = await FirebaseFirestore.instance
          .collection('Itinerary')
          .where(FieldPath.documentId, whereIn: itineraryIds)
          .get();

      // Map results to a list of maps
      List<Map<String, dynamic>> itineraries = itinerarySnapshot.docs
          .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
          .toList();

      for (var itinerary in itineraries) {
        String itineraryId = itinerary['id'];

        // Get the members of this itinerary
        QuerySnapshot memberSnapshot = await FirebaseFirestore.instance
            .collection('ItineraryMember')
            .where('itinerary_id', isEqualTo: itineraryId)
            .get();

        bool isOwnerInThisItinerary = false;

        // Loop through members to check if the current user is the "Owner"
        for (var memberDoc in memberSnapshot.docs) {
          var memberData = memberDoc.data();

          // Ensure memberData is not null before accessing it
          for (var memberDoc in memberSnapshot.docs) {
            var memberData = memberDoc.data() as Map<String,
                dynamic>?; // Cast to Map<String, dynamic> if it's not null

            // Ensure memberData is not null before accessing it
            if (memberData != null &&
                memberData['user_id'] == userId &&
                memberData['role'] == 'Owner') {
              isOwnerInThisItinerary = true;
              break;
            }
          }
        }

        // Set the isOwner flag for the itinerary
        itinerary['isOwner'] = isOwnerInThisItinerary;
      }

      return itineraries;
    } catch (error) {
      print('Error fetching user itineraries: $error');
      return [];
    }
  }

  Future<bool> addMemberToItinerary(
      String itineraryId, String userId, String role) async {
    try {
      // Create a new member document in the 'ItineraryMember' collection
      await FirebaseFirestore.instance.collection('ItineraryMember').add({
        'itinerary_id': itineraryId,
        'user_id': userId,
        'role': role,
        'joined_date': DateTime.now(),
      });
      return true;
    } catch (e) {
      print("Error adding member: $e");
      return false;
    }
  }

  Future<List<ItineraryMember>> getItineraryMembers(String itineraryId) async {
    List<ItineraryMember> membersList = [];

    try {
      // Query the members of a specific itinerary
      QuerySnapshot membersSnapshot = await FirebaseFirestore.instance
          .collection('ItineraryMember')
          .where('itinerary_id', isEqualTo: itineraryId)
          .get();

      if (membersSnapshot.docs.isNotEmpty) {
        // Loop through each member document
        for (var doc in membersSnapshot.docs) {
          String userId = doc['user_id'];
          String role = doc['role'];
          DateTime joinedDate = (doc['joined_date'] is Timestamp)
              ? (doc['joined_date'] as Timestamp).toDate()
              : DateTime.parse(doc['joined_date'] as String);

          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('User')
              .doc(userId)
              .get();

          String username = userDoc.exists ? userDoc['username'] : 'Unknown';
          String profilePic = userDoc.exists ? userDoc['profile_picture'] : '';

          membersList.add(ItineraryMember(
              userId: userId,
              username: username,
              profilePic: profilePic,
              role: role,
              joinedDate: joinedDate));
        }
      }
    } catch (e) {
      print("Error fetching itinerary members: $e");
    }

    return membersList;
  }

  Future<void> updateRoleInFirestore(
      String memberId, String newRole, String itineraryId) async {
    try {
      final invitationSnapshot = await FirebaseFirestore.instance
          .collection('ItineraryInvite')
          .where('user_id', isEqualTo: memberId)
          .where('itinerary_id', isEqualTo: itineraryId)
          .where('status', isEqualTo: 'pending')
          .get();

      if (invitationSnapshot.docs.isNotEmpty) {
        print('User has a pending invitation. Role cannot be updated.');
        return;
      }

      final inviteRef =
          FirebaseFirestore.instance.collection('ItineraryInvite').doc();
      final inviteData = {
        'itinerary_id': itineraryId,
        'user_id': memberId,
        'role': newRole,
        'invite_date': DateTime.now(),
        'status': 'pending',
      };

      await inviteRef.set(inviteData);

      await FirebaseFirestore.instance
          .collection('ItineraryMember')
          .doc(memberId)
          .update({
        'role': newRole,
      });
      print('Role updated successfully');
    } catch (e) {
      print('Error updating role: $e');
    }
  }

  // Fetch DayItinerary for a specific itinerary and day
  Future<List<ItineraryLocation>> _fetchLocationsForDay(
      String itineraryId, int dayNumber) async {
    // Fetch DayItinerary for the specified day
    var dayItinerarySnapshot = await FirebaseFirestore.instance
        .collection('DayItinerary')
        .where('itinerary_id', isEqualTo: itineraryId)
        .where('day_number', isEqualTo: dayNumber)
        .get();

    if (dayItinerarySnapshot.docs.isEmpty) {
      return [];
    }

    // Get the DayItinerary document
    var dayItineraryData = dayItinerarySnapshot.docs.first.data();
    List<String> locationIds =
        List<String>.from(dayItineraryData['location_ids']);

    // Fetch the locations based on locationIds
    List<ItineraryLocation> locations = [];
    for (String locationId in locationIds) {
      var locationSnapshot = await FirebaseFirestore.instance
          .collection('ItineraryLocation')
          .doc(locationId)
          .get();

      if (locationSnapshot.exists) {
        var locationData = locationSnapshot.data()!;
        locations
            .add(ItineraryLocation.fromMap(locationData, locationSnapshot.id));
      }
    }

    return locations;
  }
}
