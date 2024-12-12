import 'package:cloud_firestore/cloud_firestore.dart';

enum InviteStatus {
  pending,
  accepted,
  rejected,
  canceled, // Itinerary Owner cancel the inivitation
}

class ItineraryInvite {
  final String userId;
  final String role;
  final DateTime inviteDate;
  String? itineraryId;
  InviteStatus status;
  String? docId;
  String? itineraryName;

  ItineraryInvite({
    required this.userId,
    required this.role,
    required this.inviteDate,
    this.itineraryId,
    this.status = InviteStatus.pending,
    this.docId,
    this.itineraryName = '',
  });

  // Convert ItineraryInvite to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'role': role,
      'invite_date': Timestamp.fromDate(inviteDate),
      'status': status.toString().split('.').last,
    };
  }

  // Factory method to create ItineraryInvite from Firestore data
  factory ItineraryInvite.fromMap(Map<String, dynamic> data, String docId) {
    return ItineraryInvite(
      userId: data['user_id'],
      role: data['role'],
      itineraryId: (data['itinerary_id']),
      inviteDate: (data['invite_date'] is Timestamp)
          ? (data['invite_date'] as Timestamp).toDate()
          : DateTime.parse(data['invite_date']),
      status: InviteStatus.values.firstWhere(
        (e) => e.toString().split('.').last == data['status'],
        orElse: () => InviteStatus.pending, // Default to pending if not found
      ),
      docId: docId,
    );
  }
}
