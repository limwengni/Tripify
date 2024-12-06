import 'package:cloud_firestore/cloud_firestore.dart';

class RefundPackageModel {
  final String id;
  final String travelPackagePurchasedId;
  bool isAccept;
  final double price;
  final String createdBy;
  final DateTime createdAt;
  final DateTime expiredDate;
  final String travelCompanyId;
  final String travelPackageId;
  final int refundQuantity;

  RefundPackageModel({
    required this.id,
    required this.travelPackagePurchasedId,
    this.isAccept = false,
    required this.price,
    required this.createdBy,
    required this.createdAt,
    required this.expiredDate,
    required this.travelCompanyId,
    required this.travelPackageId,
    required this.refundQuantity,
  });

  // Factory method to create an instance from a Map object with null checks
  factory RefundPackageModel.fromMap(Map<String, dynamic> map) {
    if (map == null) {
      throw ArgumentError("Map cannot be null");
    }

    return RefundPackageModel(
      id: map['id'] as String? ?? '',
      travelPackagePurchasedId:
          map['travel_package_purchased_id'] as String? ?? '',
      travelPackageId: map['travel_package_id'] as String? ?? '',
      isAccept: map['is_accept'] as bool? ?? false,
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      createdBy: map['created_by'] as String? ?? '',
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      expiredDate: map['expired_date'] is DateTime
          ? map['expired_date'] as DateTime
          : (map['expired_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      travelCompanyId: map['travel_company_id'] as String? ?? '',
      refundQuantity: map['refund_quantity'] as int? ?? 0,
    );
  }

  // Method to convert the model instance to a Map object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'travel_package_purchased_id': travelPackagePurchasedId,
      'is_accept': isAccept,
      'travel_package_id': travelPackageId,
      'price': price,
      'created_by': createdBy,
      'created_at': createdAt,
      'expired_date': expiredDate,
      'travel_company_id': travelCompanyId,
      'refund_quantity': refundQuantity,
    };
  }

  // Utility method to toggle acceptance status
  void toggleAccept() {
    isAccept = !isAccept;
  }

  @override
  String toString() {
    return 'RefundPackageModel(id: $id, travelPackagePurchasedId: $travelPackagePurchasedId, isAccept: $isAccept, price: $price, createdBy: $createdBy, createdAt: $createdAt, expiredDate: $expiredDate, travelCompanyId: $travelCompanyId)';
  }
}
