// import 'package:carousel_slider/carousel_slider.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:tripify/models/conversation_model.dart';
// import 'package:tripify/models/new_travel_package_model.dart';
// import 'package:tripify/models/receipt_model.dart';
// import 'package:tripify/models/travel_package_model.dart';
// import 'package:tripify/models/travel_package_purchased_model.dart';
// import 'package:tripify/models/user_model.dart';
// import 'package:tripify/view_models/firestore_service.dart';
// import 'package:tripify/view_models/stripe_service.dart';
// import 'package:tripify/views/payment_page.dart';
// import 'package:tripify/views/payment_success_page.dart';

// class TravelPackageDetailsPage extends StatefulWidget {
//   final NewTravelPackageModel travelPackage; // Identifier for the travel package
//   final String currentUserId;
//   final UserModel travelPackageUser;
//   final String? adId;

//   const TravelPackageDetailsPage(
//       {Key? key,
//       required this.travelPackage,
//       required this.currentUserId,
//       required this.travelPackageUser,
//       this.adId})
//       : super(key: key);

//   @override
//   _TravelPackageDetailsPageState createState() =>
//       _TravelPackageDetailsPageState();
// }

// class _TravelPackageDetailsPageState extends State<TravelPackageDetailsPage> {
//   int quantity = 1;
//   FirestoreService _firestoreService = FirestoreService();

//   @override
//   void initState() {
//     super.initState();
//     addClickNum();
//     print('ad Id: ${widget.adId}');
//   }

//   void addClickNum() async {
//     Map<String, bool>? clickNum = widget.travelPackage.clickNum;
//     if (clickNum != null) {
//       if (!clickNum.containsKey(widget.currentUserId)) {
//         await _firestoreService.updateMapField('New_Travel_Packages',
//             widget.travelPackage.id, 'click_num', widget.currentUserId, true);
//       }
//     } else {
//       await _firestoreService.updateMapField('New_Travel_Packages',
//           widget.travelPackage.id, 'click_num', widget.currentUserId, true);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.travelPackage.name),
//       ),
//       body: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           ClipRRect(
//             child: Container(
//               height: 250,
//               width: double.infinity,
//               child: CarouselSlider.builder(
//                 itemCount: widget.travelPackage.images!.length,
//                 options: CarouselOptions(
//                   viewportFraction: 1,
//                   autoPlay: true,
//                   enableInfiniteScroll: false,
//                 ),
//                 itemBuilder: (ctx, index, realIdx) {
//                   return Image.network(
//                     widget.travelPackage.images![index],
//                     width: double.infinity,
//                     fit: BoxFit.cover,
//                     loadingBuilder: (context, child, loadingProgress) {
//                       if (loadingProgress == null) {
//                         return child;
//                       } else {
//                         return Shimmer.fromColors(
//                           baseColor: Colors.grey[300]!,
//                           highlightColor: Colors.grey[100]!,
//                           child: Container(
//                             width: double.infinity,
//                             height: 250,
//                             color: Colors.white,
//                           ),
//                         );
//                       }
//                     },
//                     errorBuilder: (context, error, stackTrace) {
//                       return Center(
//                         child: Icon(
//                           Icons.broken_image,
//                           size: 50,
//                           color: Colors.grey,
//                         ),
//                       );
//                     },
//                   );
//                 },
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     widget.travelPackage.name,
//                     style: TextStyle(fontSize: 22),
//                   ),
//                   const SizedBox(height: 8),
//                   Text(
//                     '${DateFormat('yyyy-MM-dd').format(widget.travelPackage.startDate)} - ${DateFormat('yyyy-MM-dd').format(widget.travelPackage.endDate)}',
//                   ),
//                   const SizedBox(height: 16),
//                   Divider(),
//                   Text(
//                     'Itinerary',
//                     style: TextStyle(fontSize: 16),
//                   ),
//                   const SizedBox(height: 2),
//                   Text(
//                     widget.travelPackage.itinerary,
//                   ),
//                   const SizedBox(height: 16),
//                   Divider(),
//                   Text(
//                     'Available slots: ${widget.travelPackage.quantityAvailable}/${widget.travelPackage.quantity}',
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       bottomNavigationBar: Container(
//         padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black.withOpacity(0.1), // Shadow color
//               offset: Offset(0, -3), // Horizontal and vertical offsets
//               blurRadius: 8, // Blur radius for soft edges
//               spreadRadius: 1, // Spread radius for the shadow
//             ),
//           ],
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               'RM ${widget.travelPackage.price.toStringAsFixed(2)}',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             ElevatedButton(
//               onPressed: () {
//                 if (widget.travelPackage.createdBy == widget.currentUserId ||
//                     widget.travelPackage.resellerId == widget.currentUserId) {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) => AlertDialog(
//                       title: const Text(
//                         'Error',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       content: const Text(
//                           'You can\'t purchased the travel package that created by you!'),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, 'OK'),
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 } else if (widget.travelPackage.quantityAvailable != 0) {
//                   _showDialog(context);
//                 } else {
//                   showDialog(
//                     context: context,
//                     builder: (BuildContext context) => AlertDialog(
//                       title: const Text(
//                         'Error',
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                       content: const Text('Sold Out!'),
//                       actions: <Widget>[
//                         TextButton(
//                           onPressed: () => Navigator.pop(context, 'OK'),
//                           child: const Text('OK'),
//                         ),
//                       ],
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                   backgroundColor: const Color.fromARGB(255, 159, 118, 249)),
//               child: const Text(
//                 'Book Now',
//                 style: TextStyle(fontSize: 16, color: Colors.white),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   void _showDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: widget.travelPackage.isResale != true
//               ? Text('Quantity Purchase')
//               : Text('Purchase Confirmation'),
//           content: StatefulBuilder(
//             builder: (BuildContext context, StateSetter setState) {
//               return widget.travelPackage.isResale != true
//                   ? Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Quantity: $quantity',
//                           style: TextStyle(fontSize: 18),
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             IconButton(
//                               icon: Icon(Icons.remove),
//                               onPressed: () {
//                                 setState(() {
//                                   if (quantity > 0) {
//                                     quantity--;
//                                   }
//                                 });
//                               },
//                             ),
//                             IconButton(
//                               icon: Icon(Icons.add),
//                               onPressed: () {
//                                 if (quantity <=
//                                     widget.travelPackage.quantityAvailable!) {
//                                   setState(() {
//                                     quantity++;
//                                   });
//                                 }
//                               },
//                             ),
//                           ],
//                         ),
//                       ],
//                     )
//                   : Column(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           'Are you sure to purchase?\nResell Travel Package can\'t select quantity and can\'t refund!',
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                       ],
//                     );
//             },
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 if (widget.travelPackage.isResale != true) {
//                   double amount = quantity * widget.travelPackage.price;
//                   bool paymentSuccess =
//                       await StripeService.instance.makePayment(amount, 'myr');
//                   List<String> ticketIdListForPurchasedModel = [];
//                   String travelPackagePurchasedId = '';

//                   if (paymentSuccess) {
//                     FirestoreService firestoreService = FirestoreService();
//                     String currentUser = FirebaseAuth.instance.currentUser!.uid;
//                     Map<String, dynamic>? travelPackagePurchasedBeforeMap;

//                     // travelPackagePurchasedBeforeMap = await firestoreService
//                     //     .getSubCollectionOneDataByTwoFields(
//                     //   'User',
//                     //   currentUser,
//                     //   'Travel_Packages_Purchased',
//                     //   'travel_package_id',
//                     //   widget.travelPackage.id,
//                     //   'is_purchase_resale_package',
//                     //   false,
//                     // );

//                     if (widget.adId != null && widget.adId!.isNotEmpty) {
//                       travelPackagePurchasedBeforeMap = await firestoreService
//                           .getSubCollectionOneDataByThreeFields(
//                         'User',
//                         currentUser,
//                         'Travel_Packages_Purchased',
//                         'travel_package_id',
//                         widget.travelPackage.id,
//                         'is_purchase_resale_package',
//                         false,
//                         'ad_id',
//                         widget.adId!,
//                       );
//                     } else {
//                       travelPackagePurchasedBeforeMap = await firestoreService
//                           .getSubCollectionOneDataByThreeFields(
//                         'User',
//                         currentUser,
//                         'Travel_Packages_Purchased',
//                         'travel_package_id',
//                         widget.travelPackage.id,
//                         'is_purchase_resale_package',
//                         false,
//                         'ad_id',
//                         '',
//                       );
//                     }

//                     String id = widget.travelPackage.id;

//                     for (int i = 0;
//                         i < widget.travelPackage.ticketIdNumMap!.length;
//                         i++) {
//                       if (quantity > ticketIdListForPurchasedModel.length &&
//                           widget.travelPackage.ticketIdNumMap!['${id}_${i}'] ==
//                               '') {
//                         ticketIdListForPurchasedModel.add('${id}_${i}');
//                         await _firestoreService.updateMapField(
//                             'New_Travel_Packages',
//                             id,
//                             'ticket_id_map',
//                             '${id}_${i}',
//                             currentUser);
//                       }
//                     }

//                     // Assuming `travelPackagePurchasedBeforeMap` is the existing record fetched from Firestore
//                     if (travelPackagePurchasedBeforeMap == null) {
//                       TravelPackagePurchasedModel travelPackagePurchased;
//                       if (widget.adId != null && widget.adId!.isNotEmpty) {
//                         travelPackagePurchased = TravelPackagePurchasedModel(
//                           id: '',
//                           travelPackageId: widget.travelPackage.id,
//                           price: amount,
//                           quantity: quantity,
//                           ticketIdList: ticketIdListForPurchasedModel,
//                           isPurchaseResalePackage: false,
//                           adId: widget.adId!,
//                         );
//                       } else {
//                         travelPackagePurchased = TravelPackagePurchasedModel(
//                           id: '',
//                           travelPackageId: widget.travelPackage.id,
//                           price: amount,
//                           quantity: quantity,
//                           ticketIdList: ticketIdListForPurchasedModel,
//                           isPurchaseResalePackage: false,
//                           adId: '', 
//                         );
//                       }

//                       // Insert the new record into Firestore
//                       travelPackagePurchasedId = await _firestoreService
//                           .insertSubCollectionDataWithAutoIDReturnValue(
//                         'User',
//                         'Travel_Packages_Purchased',
//                         currentUser,
//                         travelPackagePurchased.toMap(),
//                       );

//                       // Add the user to the conversation (chat)
//                       List<String> newItem = [widget.currentUserId];
//                       await _firestoreService.addItemToCollectionList(
//                         documentId: widget.travelPackage.groupChatId!,
//                         collectionName: 'Conversations',
//                         fieldName: 'participants',
//                         newItems: newItem,
//                       );

//                       // Update unread message count
//                       await _firestoreService.updateMapField(
//                         'Conversations',
//                         widget.travelPackage.groupChatId!,
//                         'unread_message',
//                         currentUser,
//                         0,
//                       );
//                     } else {
//                       // Check for Ads Purchase
//                       if (widget.adId != null && widget.adId!.isNotEmpty) {
//                         // If `adId` matches the previous purchase, update it
//                         if (travelPackagePurchasedBeforeMap['ad_id'] ==
//                             widget.adId) {
//                           // Update the existing purchase (same ad)
//                           travelPackagePurchasedId =
//                               travelPackagePurchasedBeforeMap['id'];
//                           int updatedQuantity =
//                               travelPackagePurchasedBeforeMap['quantity'] +
//                                   quantity;
//                           double updatedPrice =
//                               travelPackagePurchasedBeforeMap['price'] + amount;
//                           List<String> ticketListUpdated = List<String>.from(
//                               travelPackagePurchasedBeforeMap['ticket_id_list']
//                                   .map((item) => item.toString()));
//                           ticketListUpdated
//                               .addAll(ticketIdListForPurchasedModel);

//                           await _firestoreService.updateSubCollectionField(
//                             collection: 'User',
//                             documentId: currentUser,
//                             subCollection: 'Travel_Packages_Purchased',
//                             subDocumentId:
//                                 travelPackagePurchasedBeforeMap['id'],
//                             field: 'quantity',
//                             value: updatedQuantity,
//                           );

//                           await _firestoreService.updateSubCollectionField(
//                             collection: 'User',
//                             documentId: currentUser,
//                             subCollection: 'Travel_Packages_Purchased',
//                             subDocumentId:
//                                 travelPackagePurchasedBeforeMap['id'],
//                             field: 'price',
//                             value: updatedPrice,
//                           );

//                           await _firestoreService.addItemToSubCollectionList(
//                             collectionName: 'User',
//                             documentId: currentUser,
//                             subCollectionName: 'Travel_Packages_Purchased',
//                             subDocumentId:
//                                 travelPackagePurchasedBeforeMap['id'],
//                             fieldName: 'ticket_id_list',
//                             newItems: ticketListUpdated,
//                           );
//                         } else {
//                           // Different `adId`, create a new record for Ads purchase
//                           TravelPackagePurchasedModel travelPackagePurchased =
//                               TravelPackagePurchasedModel(
//                             id: '',
//                             travelPackageId: widget.travelPackage.id,
//                             price: amount,
//                             quantity: quantity,
//                             ticketIdList: ticketIdListForPurchasedModel,
//                             isPurchaseResalePackage: false,
//                             adId:
//                                 widget.adId!, // Include `adId` for Ads purchase
//                           );

//                           travelPackagePurchasedId = await _firestoreService
//                               .insertSubCollectionDataWithAutoIDReturnValue(
//                             'User',
//                             'Travel_Packages_Purchased',
//                             currentUser,
//                             travelPackagePurchased.toMap(),
//                           );

//                           List<String> newItem = [widget.currentUserId];
//                           await _firestoreService.addItemToCollectionList(
//                             documentId: widget.travelPackage.groupChatId!,
//                             collectionName: 'Conversations',
//                             fieldName: 'participants',
//                             newItems: newItem,
//                           );

//                           await _firestoreService.updateMapField(
//                             'Conversations',
//                             widget.travelPackage.groupChatId!,
//                             'unread_message',
//                             currentUser,
//                             0,
//                           );
//                         }
//                       } else {
//                         // Marketplace purchase that has already been made
//                         if (travelPackagePurchasedBeforeMap['ad_id'] == '' &&
//                             travelPackagePurchasedBeforeMap[
//                                     'travel_package_id'] ==
//                                 widget.travelPackage.id) {
//                           travelPackagePurchasedId =
//                               travelPackagePurchasedBeforeMap['id'];
//                           int updatedQuantity =
//                               travelPackagePurchasedBeforeMap['quantity'] +
//                                   quantity;
//                           double updatedPrice =
//                               travelPackagePurchasedBeforeMap['price'] + amount;
//                           List<String> ticketListUpdated = List<String>.from(
//                               travelPackagePurchasedBeforeMap['ticket_id_list']
//                                   .map((item) => item.toString()));
//                           ticketListUpdated
//                               .addAll(ticketIdListForPurchasedModel);

//                           // Update the existing record with updated quantity and price
//                           await _firestoreService.updateSubCollectionField(
//                             collection: 'User',
//                             documentId: currentUser,
//                             subCollection: 'Travel_Packages_Purchased',
//                             subDocumentId:
//                                 travelPackagePurchasedBeforeMap['id'],
//                             field: 'quantity',
//                             value: updatedQuantity,
//                           );

//                           await _firestoreService.updateSubCollectionField(
//                             collection: 'User',
//                             documentId: currentUser,
//                             subCollection: 'Travel_Packages_Purchased',
//                             subDocumentId:
//                                 travelPackagePurchasedBeforeMap['id'],
//                             field: 'price',
//                             value: updatedPrice,
//                           );

//                           await _firestoreService.addItemToSubCollectionList(
//                             collectionName: 'User',
//                             documentId: currentUser,
//                             subCollectionName: 'Travel_Packages_Purchased',
//                             subDocumentId:
//                                 travelPackagePurchasedBeforeMap['id'],
//                             fieldName: 'ticket_id_list',
//                             newItems: ticketListUpdated,
//                           );
//                         }
//                       }
//                     }

//                     bool condition =
//                         travelPackagePurchasedBeforeMap!['ad_id'] == '' &&
//                             travelPackagePurchasedBeforeMap[
//                                     'travel_package_id'] ==
//                                 widget.travelPackage.id;
//                     print('Condition met: $condition');
//                     print(
//                         "ad id: ${travelPackagePurchasedBeforeMap['ad_id'] == ''}");

//                     //receipt part
//                     ReceiptModel receipt = ReceiptModel(
//                         id: '',
//                         userId: currentUser,
//                         travelPackagePurchasedId: travelPackagePurchasedId,
//                         createdAt: DateTime.now(),
//                         ticketIdList: ticketIdListForPurchasedModel,
//                         travelPackageId: widget.travelPackage.id);

//                     await _firestoreService.insertSubCollectionDataWithAutoID(
//                         'User', 'Receipts', currentUser, receipt.toMap());

//                     //wallet credit part
//                     double walletCreditUpdated = 0;
//                     if (widget.travelPackageUser.walletCredit != null) {
//                       walletCreditUpdated =
//                           widget.travelPackageUser.walletCredit! + amount;
//                     } else {
//                       walletCreditUpdated = amount;
//                     }

//                     await _firestoreService.updateField(
//                         'User',
//                         widget.travelPackage.createdBy,
//                         'wallet_credit',
//                         walletCreditUpdated);

//                     //update ori package quantity
//                     int quantityLeft =
//                         widget.travelPackage.quantityAvailable! - quantity;

//                     await firestoreService.updateField(
//                         'Travel_Packages',
//                         widget.travelPackage.id,
//                         'quantity_available',
//                         quantityLeft);

//                     if (quantityLeft == 0) {
//                       await firestoreService.updateField('Travel_Packages',
//                           widget.travelPackage.id, 'is_available', false);
//                     }

//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PaymentSuccessPage(
//                           orderId: widget.travelPackage.name,
//                           totalAmount: amount,
//                         ),
//                       ),
//                     );
//                   } else {
//                     // Payment failed
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Checkout Failed')),
//                     );
//                   }
//                 } else {
//                   double amount = widget.travelPackage.price;
//                   bool paymentSuccess =
//                       await StripeService.instance.makePayment(amount, 'myr');
//                   List<String> ticketIdListOfPurchasedModel = [];
//                   String travelPackagePurchasedId;

//                   if (paymentSuccess) {
//                     FirestoreService firestoreService = FirestoreService();
//                     String currentUser = FirebaseAuth.instance.currentUser!.uid;

//                     String id = widget.travelPackage.id;

//                     //get Travel Package Purchased ticket number
//                     Map<String, dynamic>? resellTravelPackagePurchasedMap =
//                         await _firestoreService.getSubCollectionDataById(
//                             collection: 'User',
//                             subCollection: 'Travel_Packages_Purchased',
//                             docId: widget.travelPackage.resellerId!,
//                             subDocId:
//                                 widget.travelPackage.travelPackagePurchasedId!);

//                     TravelPackagePurchasedModel travelPackagePurchasedModel;

//                     //process for transfer the ticket no
//                     if (resellTravelPackagePurchasedMap != null) {
//                       travelPackagePurchasedModel =
//                           TravelPackagePurchasedModel.fromMap(
//                               resellTravelPackagePurchasedMap);

//                       for (int i = 0;
//                           i < travelPackagePurchasedModel.ticketIdList.length;
//                           i++) {
//                         print('model ' +
//                             travelPackagePurchasedModel.ticketIdList
//                                 .toString());

//                         print('start part');
//                         print(widget.travelPackage.quantity);
//                         print('i = ${i}');
//                         print(ticketIdListOfPurchasedModel.length);

//                         if (widget.travelPackage.quantity >
//                             ticketIdListOfPurchasedModel.length) {
//                           ticketIdListOfPurchasedModel.add(
//                               '${travelPackagePurchasedModel.ticketIdList[i]}');

//                           print(
//                               'add: ${travelPackagePurchasedModel.ticketIdList[i]}');
//                         }
//                       }
//                       List<String> oriTicketNoList =
//                           travelPackagePurchasedModel.ticketIdList;
//                       List<String> updatedTicketNoList = oriTicketNoList
//                           .where((item) =>
//                               !ticketIdListOfPurchasedModel.contains(item))
//                           .toList();

//                       await _firestoreService.updateSubCollectionField(
//                           collection: 'User',
//                           documentId: widget.travelPackage.resellerId!,
//                           subCollection: 'Travel_Packages_Purchased',
//                           subDocumentId:
//                               widget.travelPackage.travelPackagePurchasedId!,
//                           field: 'ticket_id_list',
//                           value: updatedTicketNoList);
//                     }

//                     //add travel package purchased
//                     TravelPackagePurchasedModel travelPackagePurchased =
//                         TravelPackagePurchasedModel(
//                       id: '',
//                       travelPackageId:
//                           widget.travelPackage.travelPackageIdForResale!,
//                       price: amount,
//                       quantity: widget.travelPackage.quantity,
//                       ticketIdList: ticketIdListOfPurchasedModel,
//                       isPurchaseResalePackage: true,
//                     );

//                     travelPackagePurchasedId = await _firestoreService
//                         .insertSubCollectionDataWithAutoIDReturnValue(
//                       'User',
//                       'Travel_Packages_Purchased',
//                       currentUser,
//                       travelPackagePurchased.toMap(),
//                     );

//                     //update the original travel package for ticket no
//                     for (int i = 0;
//                         i < ticketIdListOfPurchasedModel.length;
//                         i++) {
//                       await _firestoreService.updateMapField(
//                           'Travel_Packages',
//                           widget.travelPackage.travelPackageIdForResale!,
//                           'ticket_id_map',
//                           '${ticketIdListOfPurchasedModel[i]}',
//                           currentUser);
//                     }

//                     //group chat part
//                     Map<String, dynamic>? groupChatMap =
//                         await _firestoreService.getDataById(
//                             'Conversations', widget.travelPackage.groupChatId!);
//                     if (groupChatMap != null) {
//                       ConversationModel groupChat =
//                           ConversationModel.fromMap(groupChatMap);

//                       //only add the user into the group chat when they are not inside the group chat
//                       if (!groupChat.participants.contains(currentUser)) {
//                         List<String> newItem = [widget.currentUserId];
//                         await _firestoreService.addItemToCollectionList(
//                             documentId: widget.travelPackage.groupChatId!,
//                             collectionName: 'Conversations',
//                             fieldName: 'participants',
//                             newItems: newItem);

//                         await _firestoreService.updateMapField(
//                             'Conversations',
//                             widget.travelPackage.groupChatId!,
//                             'unread_message',
//                             currentUser,
//                             0);
//                       }
//                     }

//                     //receipt part
//                     ReceiptModel receipt = ReceiptModel(
//                         id: '',
//                         userId: currentUser,
//                         travelPackagePurchasedId: travelPackagePurchasedId,
//                         createdAt: DateTime.now(),
//                         ticketIdList: ticketIdListOfPurchasedModel,
//                         travelPackageId: widget.travelPackage.id);

//                     await _firestoreService.insertSubCollectionDataWithAutoID(
//                         'User', 'Receipts', currentUser, receipt.toMap());

//                     //wallet credit part
//                     Map<String, dynamic>? resellerMap = await _firestoreService
//                         .getDataById('User', widget.travelPackage.resellerId!);
//                     if (resellerMap != null) {
//                       UserModel reseller = UserModel.fromMap(
//                           resellerMap, widget.travelPackage.resellerId!);

//                       //update reseller wallet
//                       double walletCreditUpdated = 0;
//                       if (reseller.walletCredit != null) {
//                         walletCreditUpdated = reseller.walletCredit! + amount;
//                       } else {
//                         walletCreditUpdated = amount;
//                       }
//                       await _firestoreService.updateField(
//                           'User',
//                           widget.travelPackage.resellerId!,
//                           'wallet_credit',
//                           walletCreditUpdated);
//                     }

//                     //change state for the resale travel package
//                     await _firestoreService.updateField('Travel_Packages',
//                         widget.travelPackage.id, 'is_available', false);

//                     //decrease the resell quantity for the travel package purchased of the reseller
//                     await _firestoreService.incrementFieldInSubCollection(
//                         'User',
//                         widget.travelPackage.resellerId!,
//                         'Travel_Packages_Purchased',
//                         widget.travelPackage.travelPackagePurchasedId!,
//                         -widget.travelPackage.quantity,
//                         'resale_quantity');

//                     //increase the sold quantity for the travel package purchased of the reseller
//                     await _firestoreService.incrementFieldInSubCollection(
//                         'User',
//                         widget.travelPackage.resellerId!,
//                         'Travel_Packages_Purchased',
//                         widget.travelPackage.travelPackagePurchasedId!,
//                         widget.travelPackage.quantity,
//                         'sold');

//                     //check the reseller still have the package or not, if no more package then it will be kick out to the group chat
//                     Map<String, dynamic>? travelPackageMapForChecking =
//                         await _firestoreService.getDataById('Travel_Packages',
//                             widget.travelPackage.travelPackageIdForResale!);

//                     if (travelPackageMapForChecking != null) {
//                       TravelPackageModel travelPackageModelForChecking =
//                           TravelPackageModel.fromMap(
//                               travelPackageMapForChecking);
//                       print('travelPackge if 1');
//                       if (!travelPackageModelForChecking.ticketIdNumMap!
//                           .containsValue(widget.travelPackage.resellerId)) {
//                         print('travelPackge if 2');
//                         await _firestoreService.removeItemFromFirestoreList(
//                             collectionPath: 'Conversations',
//                             documentId: widget.travelPackage.groupChatId!,
//                             fieldName: 'participants',
//                             itemToRemove: widget.travelPackage.resellerId!);
//                       }
//                     }

//                     // Map<String, dynamic>?
//                     //     travelPackagePurchasedForCheckSoldandOwnMap =
//                     //     await _firestoreService.getSubCollectionDataById(
//                     //         collection: 'User',
//                     //         subCollection: 'Travel_Packages_Purchased',
//                     //         docId: widget.travelPackage.resellerId!,
//                     //         subDocId:
//                     //             widget.travelPackage.travelPackagePurchasedId!);
//                     // if (travelPackagePurchasedForCheckSoldandOwnMap != null) {
//                     //   TravelPackagePurchasedModel
//                     //       travelPackagePurchasedForCheckSoldandOwn =
//                     //       TravelPackagePurchasedModel.fromMap(
//                     //           travelPackagePurchasedForCheckSoldandOwnMap);
//                     //           if(travelPackagePurchasedForCheckSoldandOwn.quantity == travelPackagePurchasedForCheckSoldandOwn.soldQuantity){
//                     //             //
//                     //           }
//                     // }
//                     Navigator.pushReplacement(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => PaymentSuccessPage(
//                           orderId: widget.travelPackage.name,
//                           totalAmount: amount,
//                         ),
//                       ),
//                     );
//                   } else {
//                     // Payment failed
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Checkout Failed')),
//                     );
//                   }
//                 }
//               },
//               child: const Text('Confirm'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
