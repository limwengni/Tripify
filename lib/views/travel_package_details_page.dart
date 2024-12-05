import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/receipt_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/view_models/stripe_service.dart';
import 'package:tripify/views/payment_page.dart';
import 'package:tripify/views/payment_success_page.dart';

class TravelPackageDetailsPage extends StatefulWidget {
  final TravelPackageModel travelPackage; // Identifier for the travel package
  final String currentUserId;
  final UserModel travelPackageUser;

  const TravelPackageDetailsPage(
      {Key? key,
      required this.travelPackage,
      required this.currentUserId,
      required this.travelPackageUser})
      : super(key: key);

  @override
  _TravelPackageDetailsPageState createState() =>
      _TravelPackageDetailsPageState();
}

class _TravelPackageDetailsPageState extends State<TravelPackageDetailsPage> {
  int quantity = 1;
  FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    addClickNum();
  }

  void addClickNum() async {
    Map<String, bool>? clickNum = widget.travelPackage.clickNum;
    if (clickNum != null) {
      if (!clickNum.containsKey(widget.currentUserId)) {
        await _firestoreService.updateMapField('Travel_Packages',
            widget.travelPackage.id, 'click_num', widget.currentUserId, true);
      }
    } else {
      await _firestoreService.updateMapField('Travel_Packages',
          widget.travelPackage.id, 'click_num', widget.currentUserId, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.travelPackage.name),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            child: Container(
              height: 250,
              width: double.infinity,
              child: CarouselSlider.builder(
                itemCount: widget.travelPackage.images!.length,
                options: CarouselOptions(
                  viewportFraction: 1,
                  autoPlay: true,
                  enableInfiniteScroll: false,
                ),
                itemBuilder: (ctx, index, realIdx) {
                  return Image.network(
                    widget.travelPackage.images![index],
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      } else {
                        return Shimmer.fromColors(
                          baseColor: Colors.grey[300]!,
                          highlightColor: Colors.grey[100]!,
                          child: Container(
                            width: double.infinity,
                            height: 250,
                            color: Colors.white,
                          ),
                        );
                      }
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.broken_image,
                          size: 50,
                          color: Colors.grey,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.travelPackage.name,
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('yyyy-MM-dd').format(widget.travelPackage.startDate)} - ${DateFormat('yyyy-MM-dd').format(widget.travelPackage.endDate)}',
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  Text(
                    'Itinerary',
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.travelPackage.itinerary,
                  ),
                  const SizedBox(height: 16),
                  Divider(),
                  Text(
                    'Available slots: ${widget.travelPackage.quantityAvailable}/${widget.travelPackage.quantity}',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              offset: Offset(0, -3), // Horizontal and vertical offsets
              blurRadius: 8, // Blur radius for soft edges
              spreadRadius: 1, // Spread radius for the shadow
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RM${widget.travelPackage.price.toStringAsFixed(2)}',
            ),
            ElevatedButton(
              onPressed: () {
                if (widget.travelPackage.createdBy == widget.currentUserId ||
                    widget.travelPackage.resellerId == widget.currentUserId) {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        'Error',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text(
                          'You can\'t purchased the travel package that created by you!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else if (widget.travelPackage.quantityAvailable != 0) {
                  _showDialog(context);
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text(
                        'Error',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      content: const Text('Sold Out!'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'OK'),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: const Text(
                'Book Now',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: widget.travelPackage.isResale != true
              ? Text('Quantity Purchase')
              : Text('Purchase Confirmation'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return widget.travelPackage.isResale != true
                  ? Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Quantity: $quantity',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.remove),
                              onPressed: () {
                                setState(() {
                                  if (quantity > 0) {
                                    quantity--;
                                  }
                                });
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.add),
                              onPressed: () {
                                if (quantity <=
                                    widget.travelPackage.quantityAvailable!) {
                                  setState(() {
                                    quantity++;
                                  });
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          height: 20,
                        ),
                        Text(
                          'Are you sure to purchase?\nResell Travel Package can\'t select quantity!',
                          style: TextStyle(fontSize: 18),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (widget.travelPackage.isResale != true) {
                  double amount = quantity * widget.travelPackage.price;
                  bool paymentSuccess =
                      await StripeService.instance.makePayment(amount, 'myr');
                  List<String> ticketIdListForPurchasedModel = [];
                  String travelPackagePurchasedId;

                  if (paymentSuccess) {
                    FirestoreService firestoreService = FirestoreService();
                    String currentUser = FirebaseAuth.instance.currentUser!.uid;
                    Map<String, dynamic>? travelPackagePurchasedBeforeMap;

                    travelPackagePurchasedBeforeMap =
                        await firestoreService.getSubCollectionOneDataByFields(
                            'User',
                            currentUser,
                            'Travel_Packages_Purchased',
                            'travel_package_id',
                            widget.travelPackage.id);

                    String id = widget.travelPackage.id;

                    for (int i = 0;
                        i < widget.travelPackage.ticketIdNumMap!.length;
                        i++) {
                      if (quantity > ticketIdListForPurchasedModel.length &&
                          widget.travelPackage.ticketIdNumMap!['${id}_${i}'] ==
                              '') {
                        ticketIdListForPurchasedModel.add('${id}_${i}');
                        await _firestoreService.updateMapField(
                            'Travel_Packages',
                            id,
                            'ticket_id_map',
                            '${id}_${i}',
                            currentUser);
                      }
                    }

                    if (travelPackagePurchasedBeforeMap == null) {
                      TravelPackagePurchasedModel travelPackagePurchased =
                          TravelPackagePurchasedModel(
                        id: '',
                        travelPackageId: widget.travelPackage.id,
                        price: amount,
                        quantity: quantity,
                        ticketIdList: ticketIdListForPurchasedModel,
                      );

                      travelPackagePurchasedId = await _firestoreService
                          .insertSubCollectionDataWithAutoIDReturnValue(
                        'User',
                        'Travel_Packages_Purchased',
                        currentUser,
                        travelPackagePurchased.toMap(),
                      );

                      List<String> newItem = [widget.currentUserId];
                      await _firestoreService.addItemToCollectionList(
                          documentId: widget.travelPackage.groupChatId!,
                          collectionName: 'Conversations',
                          fieldName: 'participants',
                          newItems: newItem);

                      await _firestoreService.updateMapField(
                          'Conversations',
                          widget.travelPackage.groupChatId!,
                          'unread_message',
                          currentUser,
                          0);
                    } else {
                      travelPackagePurchasedId =
                          travelPackagePurchasedBeforeMap['id'];
                      int updatedQuantity =
                          travelPackagePurchasedBeforeMap['quantity'] +
                              quantity;
                      List<String> ticketListUpdated = [];
                      if (travelPackagePurchasedBeforeMap != null &&
                          travelPackagePurchasedBeforeMap['ticket_id_list']
                              is List) {
                        ticketListUpdated = List<String>.from(
                            travelPackagePurchasedBeforeMap['ticket_id_list']
                                .map((item) => item.toString()));
                      }
                      ticketListUpdated.addAll(ticketIdListForPurchasedModel);
                      print(travelPackagePurchasedBeforeMap['id']);

                      await _firestoreService.updateSubCollectionField(
                        collection: 'User',
                        documentId: currentUser,
                        subCollection: 'Travel_Packages_Purchased',
                        subDocumentId: travelPackagePurchasedBeforeMap['id'],
                        field: 'quantity',
                        value: updatedQuantity,
                      );

                      await _firestoreService.addItemToSubCollectionList(
                        collectionName: 'User',
                        documentId: currentUser,
                        subCollectionName: 'Travel_Packages_Purchased',
                        subDocumentId: travelPackagePurchasedBeforeMap['id'],
                        fieldName: 'ticket_id_list',
                        newItems: ticketListUpdated,
                      );
                    }

                    //receipt part
                    ReceiptModel receipt = ReceiptModel(
                        id: '',
                        userId: currentUser,
                        travelPackagePurchasedId: travelPackagePurchasedId,
                        createdAt: DateTime.now(),
                        ticketIdList: ticketIdListForPurchasedModel,
                        travelPackageId: widget.travelPackage.id);

                    await _firestoreService.insertSubCollectionDataWithAutoID(
                        'User', 'Receipts', currentUser, receipt.toMap());

                    //wallet credit part
                    double walletCreditUpdated = 0;
                    if (widget.travelPackageUser.walletCredit != null) {
                      walletCreditUpdated =
                          widget.travelPackageUser.walletCredit! + amount;
                    } else {
                      walletCreditUpdated = amount;
                    }

                    await _firestoreService.updateField(
                        'User',
                        widget.travelPackage.createdBy,
                        'wallet_credit',
                        walletCreditUpdated);

                    //update ori package quantity
                    int quantityLeft =
                        widget.travelPackage.quantityAvailable! - quantity;

                    await firestoreService.updateField(
                        'Travel_Packages',
                        widget.travelPackage.id,
                        'quantity_available',
                        quantityLeft);

                    if (quantityLeft == 0) {
                      await firestoreService.updateField('Travel_Packages',
                          widget.travelPackage.id, 'is_available', false);
                    }

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccessPage(
                          orderId: widget.travelPackage.name,
                          totalAmount: amount,
                        ),
                      ),
                    );
                  } else {
                    // Payment failed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout Failed')),
                    );
                  }
                } else {
                  double amount = widget.travelPackage.price;
                  bool paymentSuccess =
                      await StripeService.instance.makePayment(amount, 'myr');
                  List<String> ticketIdListOfPurchasedModel = [];
                  String travelPackagePurchasedId;

                  if (paymentSuccess) {
                    FirestoreService firestoreService = FirestoreService();
                    String currentUser = FirebaseAuth.instance.currentUser!.uid;

                    String id = widget.travelPackage.id;

                    //get Travel Package Purchased ticket number
                    Map<String, dynamic>? resellTravelPackagePurchasedMap =
                        await _firestoreService.getSubCollectionDataById(
                            collection: 'User',
                            subCollection: 'Travel_Packages_Purchased',
                            docId: widget.travelPackage.resellerId!,
                            subDocId:
                                widget.travelPackage.travelPackagePurchasedId!);

                    TravelPackagePurchasedModel travelPackagePurchasedModel;

                    //process for transfer the ticket no
                    if (resellTravelPackagePurchasedMap != null) {
                      travelPackagePurchasedModel =
                          TravelPackagePurchasedModel.fromMap(
                              resellTravelPackagePurchasedMap);

                      for (int i = 0;
                          i < travelPackagePurchasedModel.ticketIdList.length;
                          i++) {
                        print('model ' +
                            travelPackagePurchasedModel.ticketIdList
                                .toString());

                        print('start part');
                        print(widget.travelPackage.quantity);
                        print('i = ${i}');
                        print(ticketIdListOfPurchasedModel.length);

                        if (widget.travelPackage.quantity >
                            ticketIdListOfPurchasedModel.length) {
                          ticketIdListOfPurchasedModel.add(
                              '${travelPackagePurchasedModel.ticketIdList[i]}');

                          print(
                              'add: ${travelPackagePurchasedModel.ticketIdList[i]}');
                        }
                      }
                      List<String> oriTicketNoList =
                          travelPackagePurchasedModel.ticketIdList;
                      List<String> updatedTicketNoList = oriTicketNoList
                          .where((item) =>
                              !ticketIdListOfPurchasedModel.contains(item))
                          .toList();

                      await _firestoreService.updateSubCollectionField(
                          collection: 'User',
                          documentId: widget.travelPackage.resellerId!,
                          subCollection: 'Travel_Packages_Purchased',
                          subDocumentId:
                              widget.travelPackage.travelPackagePurchasedId!,
                          field: 'ticket_id_list',
                          value: updatedTicketNoList);
                    }

                    TravelPackagePurchasedModel travelPackagePurchased =
                        TravelPackagePurchasedModel(
                      id: '',
                      travelPackageId:
                          widget.travelPackage.travelPackageIdForResale!,
                      price: amount,
                      quantity: widget.travelPackage.quantity,
                      ticketIdList: ticketIdListOfPurchasedModel,
                    );

                    travelPackagePurchasedId = await _firestoreService
                        .insertSubCollectionDataWithAutoIDReturnValue(
                      'User',
                      'Travel_Packages_Purchased',
                      currentUser,
                      travelPackagePurchased.toMap(),
                    );

                    print('groupchatid: ${widget.travelPackage.groupChatId}');
                    Map<String, dynamic>? groupChatMap =
                        await _firestoreService.getDataById(
                            'Conversations', widget.travelPackage.groupChatId!);
                    if (groupChatMap != null) {
                      ConversationModel groupChat =
                          ConversationModel.fromMap(groupChatMap);
                      if (!groupChat.participants.contains(currentUser)) {
                        List<String> newItem = [widget.currentUserId];
                        await _firestoreService.addItemToCollectionList(
                            documentId: widget.travelPackage.groupChatId!,
                            collectionName: 'Conversations',
                            fieldName: 'participants',
                            newItems: newItem);

                        await _firestoreService.updateMapField(
                            'Conversations',
                            widget.travelPackage.groupChatId!,
                            'unread_message',
                            currentUser,
                            0);
                      }
                    }

                    //receipt part
                    ReceiptModel receipt = ReceiptModel(
                        id: '',
                        userId: currentUser,
                        travelPackagePurchasedId: travelPackagePurchasedId,
                        createdAt: DateTime.now(),
                        ticketIdList: ticketIdListOfPurchasedModel,
                        travelPackageId: widget.travelPackage.id);

                    await _firestoreService.insertSubCollectionDataWithAutoID(
                        'User', 'Receipts', currentUser, receipt.toMap());

                    //wallet credit part
                    Map<String, dynamic>? resellerMap = await _firestoreService
                        .getDataById('User', widget.travelPackage.resellerId!);
                    if (resellerMap != null) {
                      UserModel reseller = UserModel.fromMap(
                          resellerMap, widget.travelPackage.resellerId!);

                      double walletCreditUpdated = 0;
                      if (reseller.walletCredit != null) {
                        walletCreditUpdated = reseller.walletCredit! + amount;
                      } else {
                        walletCreditUpdated = amount;
                      }
                      await _firestoreService.updateField(
                          'User',
                          widget.travelPackage.resellerId!,
                          'wallet_credit',
                          walletCreditUpdated);
                    }

                    await _firestoreService.updateField('Travel_Packages',
                        widget.travelPackage.id, 'is_available', false);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PaymentSuccessPage(
                          orderId: widget.travelPackage.name,
                          totalAmount: amount,
                        ),
                      ),
                    );
                  } else {
                    // Payment failed
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Checkout Failed')),
                    );
                  }
                }
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
