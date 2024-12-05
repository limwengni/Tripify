import 'package:cloud_firestore/cloud_firestore.dart';

class ReceiptModel {
  final String id;
  final String travelPackagePurchasedId;
  final String travelPackageId;
  final String userId;
  final DateTime createdAt;
  final List<String> ticketIdList;

  // Constructor
  ReceiptModel({
    required this.id,
    required this.travelPackagePurchasedId,
    required this.travelPackageId,
    required this.createdAt,
    required this.userId,
    required this.ticketIdList,
  });

  // Factory method for creating a ReceiptMode from a map (useful for Firestore or JSON)
  factory ReceiptModel.fromMap(Map<String, dynamic> data) {
    return ReceiptModel(
      id: data['id'] as String,
      userId: data['user_id'] as String,
      travelPackageId: data['travel_package_id'] as String,
      travelPackagePurchasedId: data['travel_package_purchased_id'] as String,
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
      ticketIdList: (data['ticket_id_list'] is List)
          ? List<String>.from(
              data['ticket_id_list'].map((item) => item.toString()))
          : [],
    );
  }

  // Method to convert a ReceiptMode object to a map (for Firestore or JSON)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'travel_package_purchased_id': travelPackagePurchasedId,
      'created_at': createdAt,
      'ticket_id_list': ticketIdList,
      'travel_package_id' : travelPackageId,
    };
  }
}
