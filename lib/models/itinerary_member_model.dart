import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryMember {
  String? id;
  final String userId;
  final String? username;
  final String? profilePic;
  String role;
  final DateTime joinedDate;
  final bool isTemporary;

  ItineraryMember({
    this.id,
    required this.userId,
    this.username,
    this.profilePic,
    required this.role,
    required this.joinedDate,
    this.isTemporary = false,
  });

  // Convert ItineraryMember to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'role': role,
      'joined_date': Timestamp.fromDate(joinedDate),
    };
  }

  // Factory method to create ItineraryMember from Firestore data
  factory ItineraryMember.fromMap(Map<String, dynamic> data) {
    return ItineraryMember(
      userId: data['user_id'],
      role: data['role'],
      joinedDate: (data['joined_date'] is Timestamp)
          ? (data['joined_date'] as Timestamp).toDate()
          : DateTime.parse(data['joined_date']),
    );
  }

  factory ItineraryMember.fromFirestore(DocumentSnapshot doc) {
    var data = doc.data() as Map<String, dynamic>;
    return ItineraryMember(
      id: doc.id,
      userId: data['user_id'],
      username: data['username'],
      profilePic: data['profile_pic'],
      role: data['role'],
      joinedDate: (data['joined_date'] as Timestamp).toDate(),
    );
  }
}
