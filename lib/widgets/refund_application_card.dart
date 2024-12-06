import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:tripify/models/refund_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/view_models/stripe_service.dart';
import 'package:tripify/views/travel_package_details_page.dart';

class RefundApplicationCard extends StatefulWidget {
  final RefundPackageModel refundPackage;
  final String currentUserId;
  const RefundApplicationCard(
      {super.key, required this.refundPackage, required this.currentUserId});

  @override
  _RefundApplicationCardState createState() => _RefundApplicationCardState();
}

class _RefundApplicationCardState extends State<RefundApplicationCard> {
  FirestoreService _firestoreService = FirestoreService();
  TravelPackageModel? travelPackage;
  TravelPackagePurchasedModel? travelPackagePurchased;
  bool travelPackageLoaded = false;
  String packageName = '';
  double? refundAmount;
  bool isAccept = false;
  
  @override
  void initState() {
  isAccept = widget.refundPackage.isAccept;
    super.initState();
    fetchTravelPackage();
  }

  void fetchTravelPackage() async {
    Map<String, dynamic>? travelPackageMap;
    travelPackageMap = await _firestoreService.getDataById(
        'Travel_Packages', widget.refundPackage.travelPackageId);

    print('docID: ${widget.refundPackage.createdBy}');
    print('subDocId: ${widget.refundPackage.travelPackagePurchasedId}');
    Map<String, dynamic>? travelPackagePurchasedMap;
    travelPackagePurchasedMap =
        await _firestoreService.getSubCollectionDataById(
            collection: 'User',
            subCollection: 'Travel_Packages_Purchased',
            docId: widget.refundPackage.createdBy,
            subDocId: widget.refundPackage.travelPackagePurchasedId);

    setState(() {
      if (travelPackageMap != null) {
        travelPackage = TravelPackageModel.fromMap(travelPackageMap);
        if (travelPackage != null) {
          travelPackageLoaded = true;
          packageName = travelPackage!.name;
        }
      }

      if (travelPackagePurchasedMap != null) {
        travelPackagePurchased =
            TravelPackagePurchasedModel.fromMap(travelPackagePurchasedMap);
        print('%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%' + travelPackagePurchased!.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    refundAmount = widget.refundPackage.price;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Stack(children: [
        Card(
            child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Refund ID: ${widget.refundPackage.id}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold, // Makes the text bold
                  fontSize: 17, // Adjust size for a title
                ),
              ),
              Text(
                  'Travel Package ID: ${widget.refundPackage.travelPackageId}'),
              if (travelPackage != null) Text('Travel Package: ${packageName}'),
              Text('Refund Quantity: ${widget.refundPackage.refundQuantity}'),
              Text('Refund Amount: RM ${refundAmount!.toStringAsFixed(2)}'),
              SizedBox(
                height: 5,
              ),
              Row(
                children: [
                  Spacer(),
                  TextButton(
                    onPressed: () async {
                      await _firestoreService.updateSubCollectionField(
                          collection: 'User',
                          documentId: widget.refundPackage.createdBy,
                          subCollection: 'Travel_Packages_Purchased',
                          subDocumentId:
                              widget.refundPackage.travelPackagePurchasedId,
                          field: 'is_refunding',
                          value: false);
                      await _firestoreService.deleteData(
                          'Refund_Packages', widget.refundPackage.id);
                    },
                    child: Text('Decline'),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 159, 118, 249), // Blue background color
                      foregroundColor: Colors
                          .white, // Text color (white text on blue background)
                      padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12), // Optional: adjust padding
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  TextButton(
                    onPressed: () async {
                      double amount = widget.refundPackage.price;
                      bool paymentSuccess = await StripeService.instance
                          .makePayment(amount, 'myr');

                      if (paymentSuccess) {
                        //update the refund state in the travel package purchased
                        await _firestoreService.updateSubCollectionField(
                            collection: 'User',
                            documentId: widget.refundPackage.createdBy,
                            subCollection: 'Travel_Packages_Purchased',
                            subDocumentId:
                                widget.refundPackage.travelPackagePurchasedId,
                            field: 'is_refund',
                            value: true);

                        print(
                            'process update refund state in the travel package purchased');

                        //update the ticket id list in the travel package(original)
                        for (int i = 0;
                            i < travelPackagePurchased!.ticketIdList.length;
                            i++) {
                          await _firestoreService.updateMapField(
                              'Travel_Packages',
                              widget.refundPackage.travelPackageId,
                              'ticket_id_map',
                              travelPackagePurchased!.ticketIdList[i],
                              '');
                        }

                        print(
                            'process update the ticket id list in the travel package(original)');

                        //update the ticket id list in the travel package purchased
                        await _firestoreService.updateSubCollectionField(
                            collection: 'User',
                            documentId: widget.refundPackage.createdBy,
                            subCollection: 'Travel_Packages_Purchased',
                            subDocumentId:
                                widget.refundPackage.travelPackagePurchasedId,
                            field: 'ticket_id_list',
                            value: null);

                        print(
                            'process update the ticket id list in the travel package purchased');

                        //update wallet amount for the customer
                        Map<String, dynamic>? refundCreatorMap =
                            await _firestoreService.getDataById(
                                'User', widget.refundPackage.createdBy);
                        UserModel refundCreator;
                        double updatedAmount = 0;

                        if (refundCreatorMap != null) {
                          refundCreator = UserModel.fromMap(
                              refundCreatorMap, widget.refundPackage.createdBy);

                          updatedAmount = refundCreator.walletCredit! + amount;

                          print(
                              'updatedAmount = ${refundCreator.walletCredit} + ${amount}');
                          print('updatedAmount = ${updatedAmount}');
                        }

                        await _firestoreService.updateField(
                            'User',
                            widget.refundPackage.createdBy,
                            'wallet_credit',
                            updatedAmount);

                        print('process update wallet credit');

                        //update the refund application to is accept == true
                        await _firestoreService.updateField('Refund_Packages',
                            widget.refundPackage.id, 'is_accept', true);

                        print(
                            'process update the refund application to is accept == true');

                        setState(() {
                          isAccept = true;
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Refund Failed')));
                      }
                    },
                    child: Text('Accept'),
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 159, 118, 249), // Blue background color
                      foregroundColor: Colors
                          .white, // Text color (white text on blue background)
                      padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12), // Optional: adjust padding
                    ),
                  )
                ],
              )
            ],
          ),
        ),),
         if (isAccept)
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Container(
                decoration: BoxDecoration(
                  color:
                      Colors.black.withOpacity(0.5), // Grey transparent overlay
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: Center(
                  child: Text(
                    'Refund',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ]),
    );
  }
}
