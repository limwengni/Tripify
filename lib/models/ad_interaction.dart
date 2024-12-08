import 'package:cloud_firestore/cloud_firestore.dart';

class AdInteraction {
  final String adId;
  final String userId;
  final DateTime timestamp;

  AdInteraction({
    required this.adId,
    required this.userId,
    required this.timestamp,
  });

  // Convert to map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'ad_id': adId,
      'user_id': userId,
      'timestamp': timestamp,
    };
  }

  // Convert from map
  factory AdInteraction.fromMap(Map<String, dynamic> map) {
    return AdInteraction(
      adId: map['ad_id'] ?? '',
      userId: map['user_id'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
    );
  }
}
