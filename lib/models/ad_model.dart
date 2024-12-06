import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  final String id;
  final String packageId;
  final String adType;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // "ongoing", "ended"
  final String renewalType;
  final DateTime createdAt;

  Advertisement({
    required this.id,
    required this.packageId,
    required this.adType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.renewalType,
    required this.createdAt,
  });

  // Convert Advertisement object to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'package_id': packageId,
      'ad_type': adType,
      'start_date': startDate,
      'end_date': endDate,
      'status': status,
      'renewal_type': renewalType,
      'created_at': createdAt,
    };
  }

  // Create Advertisement object from Firestore document
  factory Advertisement.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Advertisement(
      id: doc.id,
      packageId: data['package_id'] ?? '',
      adType: data['ad_type'] ?? '',
      startDate: (data['start_date'] as Timestamp).toDate(),
      endDate: (data['end_date'] as Timestamp).toDate(),
      status: data['status'] ?? '',
      renewalType: data['renewal_type'] ?? '',
      createdAt: (data['created_at'] as Timestamp).toDate(),
    );
  }
}
