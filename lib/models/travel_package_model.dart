// import 'package:cloud_firestore/cloud_firestore.dart';

// class TravelPackageModel {
//   // Properties
//   final String id; // Unique identifier for the package
//   final String name; // Name of the travel package
//   final String itinerary; // Description of the package
//   final double price; // Price of the package
//   final int? duration; // Duration in days
//   final DateTime startDate; // Start date of the package
//   final DateTime endDate;
//   final DateTime createdAt;
//   final int quantity; // End date of the package
//   final int quantityAvailable;
//   final List<String>? includedActivities; // List of activities included
//   final bool isAvailable; // Availability status
//   final List<String>? images;
//   final String createdBy;
//   final bool isOffer;
//   final double? offerPrice;
//   final String? groupChatId;
//   final String? resellerId;
//   final bool? isResale;
//   final String? travelPackageIdForResale;
//   final String? travelPackagePurchasedId;
//   Map<String, bool>? clickNum;
//   Map<String, bool>? viewNum;
//   Map<String, bool>? saveNum;
//   Map<String, String?>? ticketIdNumMap;

//   // Constructor
//   TravelPackageModel({
//     required this.id,
//     required this.name,
//     required this.itinerary,
//     required this.price,
//     this.duration,
//     required this.startDate,
//     required this.endDate,
//     required this.quantity,
//     this.includedActivities,
//     this.isAvailable = true,
//     required this.images,
//     required this.createdBy,
//     this.isOffer = false,
//     this.offerPrice,
//     required this.quantityAvailable,
//     required this.groupChatId,
//     this.resellerId,
//     this.isResale = false,
//     this.travelPackageIdForResale,
//     this.clickNum,
//     this.viewNum,
//     this.saveNum,
//     this.travelPackagePurchasedId,
//     required this.createdAt,
//     required this.ticketIdNumMap,
//   });

//   // Factory method for creating a TravelPackageModel from a JSON object
//   factory TravelPackageModel.fromMap(Map<String, dynamic> data) {
//     return TravelPackageModel(
//       id: data['id'],
//       name: data['name'],
//       itinerary: data['itinerary'],
//       price: (data['price'] as num).toDouble(), // Ensure price is a double
//       duration: data['duration'],
//       startDate: (data['start_date'] is Timestamp)
//           ? (data['start_date'] as Timestamp).toDate()
//           : DateTime.parse(data['start_date']),
//       endDate: (data['end_date'] is Timestamp)
//           ? (data['end_date'] as Timestamp).toDate()
//           : DateTime.parse(data['end_date']),
//       includedActivities: (data['included_activities'] as List<dynamic>?)
//           ?.map((e) => e.toString())
//           .toList(),
//       isAvailable: data['is_available'] ?? true,
//       quantity: data['quantity'],
//       images:
//           (data['images'] as List<dynamic>?)?.map((e) => e.toString()).toList(),
//       createdBy: data['created_by'],
//       isOffer: data['is_offer'] ?? false,
//       offerPrice: data['offer_price'] != null
//           ? (data['offer_price'] as num).toDouble()
//           : null,
//       quantityAvailable: data['quantity_available'],
//       groupChatId: data['group_chat_id'],
//       resellerId: data['reseller_id'],
//       isResale: data['is_resale'],
//       travelPackageIdForResale: data['travel_package_id_for_resale'],
//       travelPackagePurchasedId: data['travel_package_purchased_id'],
//       clickNum: data['click_num'] != null
//           ? Map<String, bool>.from(data['click_num'] as Map)
//           : null,
//       viewNum: data['view_num'] != null
//           ? Map<String, bool>.from(data['view_num'] as Map)
//           : null,
//       saveNum: data['save_num'] != null
//           ? Map<String, bool>.from(data['save_num'] as Map)
//           : null,
//       ticketIdNumMap: data['ticket_id_map'] != null
//           ? Map<String, String?>.from(data['ticket_id_map'] as Map)
//           : null,
//       createdAt: (data['created_at'] is Timestamp)
//           ? (data['created_at'] as Timestamp).toDate()
//           : DateTime.parse(data['created_at']),
//     );
//   }

//   // Method to convert TravelPackageModel to a JSON object
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'name': name,
//       'itinerary': itinerary,
//       'price': price,
//       'duration': duration,
//       'start_date': Timestamp.fromDate(startDate),
//       'end_date': Timestamp.fromDate(endDate),
//       'included_activities': includedActivities,
//       'is_available': isAvailable,
//       'quantity': quantity,
//       'images': images,
//       'created_by': createdBy,
//       'is_offer': isOffer,
//       'offer_price': offerPrice,
//       'quantity_available': quantityAvailable,
//       'group_chat_id': groupChatId,
//       'reseller_id': resellerId,
//       'is_resale': isResale,
//       'travel_package_id_for_resale': travelPackageIdForResale,
//       'click_num': clickNum,
//       'view_num': viewNum,
//       'save_num': saveNum,
//       'ticket_id_map': ticketIdNumMap,
//       'created_at': createdAt,
//       'travel_package_purchased_id': travelPackagePurchasedId,
//     };
//   }

//   // Method to calculate the remaining availability days
//   int getRemainingDays() {
//     return endDate.difference(DateTime.now()).inDays;
//   }
// }
