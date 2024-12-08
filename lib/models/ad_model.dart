import 'package:cloud_firestore/cloud_firestore.dart';

class Advertisement {
  final String id;
  final String packageId;
  final String adType;
  final DateTime startDate;
  final DateTime endDate;
  final String status; // "ongoing", "paused", "ended"
  final String renewalType;
  final DateTime createdAt;
  final double cpcRate;
  final double cpmRate;
  final double flatRate;

  Advertisement({
    required this.id,
    required this.packageId,
    required this.adType,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.renewalType,
    required this.createdAt,
    required this.cpcRate,
    required this.cpmRate,
    required this.flatRate,
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
      'cpc_rate': cpcRate,
      'cpm_rate': cpmRate,
      'flat_rate': flatRate,
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
      cpcRate: data['cpc_rate']?.toDouble() ?? 0.0,
      cpmRate: data['cpm_rate']?.toDouble() ?? 0.0,
      flatRate: data['flat_rate']?.toDouble() ?? 0.0,
    );
  }
}
