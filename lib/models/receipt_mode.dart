import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptMode {
  final String id;
  final String travelPackagePurchasedId;
  final DateTime createdAt;

  // Constructor
  ReceiptMode({
    required this.id,
    required this.travelPackagePurchasedId,
    required this.createdAt,
  });

  // Factory method for creating a ReceiptMode from a map (useful for Firestore or JSON)
  factory ReceiptMode.fromMap(Map<String, dynamic> data) {
    return ReceiptMode(
      id: data['id'] as String,
      travelPackagePurchasedId: data['travel_package_purchased_id'] as String,
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
    );
  }

  // Method to convert a ReceiptMode object to a map (for Firestore or JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'travel_package_purchased_id': travelPackagePurchasedId,
      'created_at': createdAt,
    };
  }
}
