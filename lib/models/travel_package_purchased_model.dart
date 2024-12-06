import 'package:cloud_firestore/cloud_firestore.dart';

class TravelPackagePurchasedModel {
  // Properties
  final String id; // Unique identifier for the package
  final String travelPackageId; // Name of the travel package
  final double price; // Price of the package
  final int quantity; // End date of the package
  final bool isAvailable; // Availability status
  final int? resaleQuantity;
  final int? soldQuantity;
  final List<String> ticketIdList;
  final bool isPurchaseResalePackage;

  // Constructor
  TravelPackagePurchasedModel({
    required this.id,
    required this.travelPackageId,
    required this.price,
    required this.quantity,
    this.isAvailable = true,
    this.resaleQuantity,
    this.soldQuantity,
    required this.ticketIdList,
    required this.isPurchaseResalePackage,
  });

  // Factory method for creating a TravelPackageModel from a JSON object
  factory TravelPackagePurchasedModel.fromMap(Map<String, dynamic> data) {
    return TravelPackagePurchasedModel(
      id: data['id'],
      travelPackageId: data['travel_package_id'],
      price: (data['price'] as num).toDouble(), // Ensure price is a double
      isAvailable: data['is_available'] ?? true,
      isPurchaseResalePackage: data['is_purchase_resale_package'] ?? false,
      quantity: data['quantity'],
      resaleQuantity: data['resale_quantity'] ?? 0,
      soldQuantity: data['sold'] ?? 0,
      ticketIdList: (data['ticket_id_list'] is List) 
        ? List<String>.from(data['ticket_id_list'].map((item) => item.toString())) 
        : [],  // Convert to List<String> or use an empty list
    );
  }

  // Method to convert TravelPackageModel to a JSON object
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'travel_package_id': travelPackageId,
      'price': price,
      'is_available': isAvailable,
      'is_purchase_resale_package': isPurchaseResalePackage, 
      'quantity': quantity,
      'resale_quantity': resaleQuantity ?? 0,
      'sold': soldQuantity ?? 0,
      'ticket_id_list': ticketIdList,
    };
  }
}
