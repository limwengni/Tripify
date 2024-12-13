import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/refund_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/new_travel_package_details_page.dart';
import 'package:tripify/views/travel_package_details_page.dart';

class TravelPackagePurchasedCard extends StatefulWidget {
  final TravelPackagePurchasedModel travelPackagePurchased;
  final String currentUserId;

  const TravelPackagePurchasedCard(
      {super.key,
      required this.travelPackagePurchased,
      required this.currentUserId});

  @override
  _TravelPackagePurchasedCardState createState() =>
      _TravelPackagePurchasedCardState();
}

class _TravelPackagePurchasedCardState
    extends State<TravelPackagePurchasedCard> {
  FirestoreService _firestoreService = FirestoreService();
  UserModel? travelCompanyUser;
  bool userLoaded = false;
  NewTravelPackageModel? travelPackage;
  int quantity = 1;
  int resaleQuantity = 0;
  int resaleAvailable = 0;
  int sold = 0;
  NewTravelPackageModel? travelPackageResale;
  bool isRefunding = false;
  bool isRefund = false;
  @override
  void initState() {
    resaleQuantity = widget.travelPackagePurchased.resaleQuantity!;
    resaleAvailable = widget.travelPackagePurchased.quantity -
        widget.travelPackagePurchased.resaleQuantity! -
        widget.travelPackagePurchased.soldQuantity!;

    print('resale available: ${resaleAvailable}');
    sold = widget.travelPackagePurchased.soldQuantity!;
    isRefunding = widget.travelPackagePurchased.isRefunding;
    isRefund = widget.travelPackagePurchased.isRefund;
    super.initState();
    fetchTravelPackageAndTravelCompany();
  }

  void fetchTravelPackageAndTravelCompany() async {
    Map<String, dynamic>? travelPackageMap;
    travelPackageMap = await _firestoreService.getDataById(
        'New_Travel_Packages', widget.travelPackagePurchased.travelPackageId);
    List<Map<String, dynamic>>? travelPackageResaleMapList;

    if (travelPackageMap != null) {
      travelPackageResaleMapList = await _firestoreService.getDataByTwoFields(
          'New_Travel_Packages',
          'reseller_id',
          widget.currentUserId,
          'travel_package_id_for_resale',
          widget.travelPackagePurchased.id);

      if (travelPackageResaleMapList.isEmpty) {
        for (int i = 0; i < travelPackageResaleMapList.length; i++) {
          travelPackageResale =
              NewTravelPackageModel.fromMap(travelPackageResaleMapList[i]);
        }
      }
      setState(() {
        travelPackage = NewTravelPackageModel.fromMap(travelPackageMap!);
      });
    } else {
      // Handle the case where travelPackageMap is null
      setState(() {
        travelPackage =
            null; // Optional: You can add a loading state or error handling
      });
    }

    if (travelPackage != null) {
      Map<String, dynamic>? userMap =
          await _firestoreService.getDataById('User', travelPackage!.createdBy);
      if (userMap != null) {
        setState(() {
          travelCompanyUser = UserModel.fromMap(userMap, userMap['id']);
          userLoaded = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!userLoaded || travelPackage == null) {
      return Center(child: CircularProgressIndicator(color: Color(0xFF9F76F9)));
    }
    return Stack(
      children: [
        GestureDetector(
          onTap: sold != quantity
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NewTravelPackageDetailsPage(
                        travelPackage: travelPackage!,
                        currentUserId: widget.currentUserId,
                        travelPackageUser: travelCompanyUser!,
                      ),
                    ),
                  );
                }
              : null,
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                  child: Container(
                    height: 150,
                    width: double.infinity,
                    child: CarouselSlider.builder(
                      itemCount: travelPackage!.images!.length,
                      options: CarouselOptions(
                        viewportFraction: 1,
                        autoPlay: true,
                        enableInfiniteScroll: false,
                      ),
                      itemBuilder: (ctx, index, realIdx) {
                        return Stack(
                          children: [
                            // Shimmer Effect
                            Positioned.fill(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // Image Network
                            Image.network(
                              travelPackage?.images?[index] ?? '',
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) {
                                  return child;
                                }
                                return Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    color: Colors.white,
                                    height: 150,
                                    width: double.infinity,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.broken_image,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  travelPackage?.name ?? 'Loading...',
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                ),
                                Text(
                                    '${DateFormat('yyyy-MM-dd').format(travelPackage!.startDate)} - ${DateFormat('yyyy-MM-dd').format(travelPackage!.endDate)}'),
                                const SizedBox(height: 5),
                              ],
                            ),
                          ),
                          Text(
                            'RM ' +
                                widget.travelPackagePurchased.price
                                    .toStringAsFixed(2),
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          travelCompanyUser != null
                              ? Container(
                                  child: CircleAvatar(
                                    radius: 15,
                                    backgroundImage: NetworkImage(
                                        travelCompanyUser!.profilePic),
                                    backgroundColor: Colors.grey[200],
                                  ),
                                )
                              : Text('loading'),
                          const SizedBox(width: 10),
                          Text(travelCompanyUser!.username),
                          SizedBox(
                            width: 10,
                          ),
                          Spacer(),
                          if (widget.travelPackagePurchased
                                  .isPurchaseResalePackage ==
                              false)
                            TextButton(
                              onPressed: () {
                                if (resaleQuantity != 0 || sold != 0) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Error'),
                                          content: Text(
                                              'You can\'t make refund for the travel package that you already resell.\nYou can remove your resell travel package then try again.'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Close the dialog
                                              },
                                              child: Text('OK'),
                                            ),
                                          ],
                                        );
                                      });
                                } else {
                                  if (!isRefunding && !isRefund) {
                                    print('first option selected!');
                                    _showRefundDialog(context);
                                  } else if (isRefunding && !isRefund) {
                                    return null;
                                  } else if (isRefund) {
                                    return null;
                                  }
                                }
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: const Color.fromARGB(255, 159,
                                    118, 249), // Blue background color
                                foregroundColor: Colors
                                    .white, // Text color (white text on blue background)
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8,
                                    horizontal: 12), // Optional: adjust padding
                              ),
                              child: isRefund != true && isRefunding != true
                                  ? const Text(
                                      'Refund') // Display 'Refund' when both conditions are false
                                  : isRefunding == true && isRefund != true
                                      ? Text(
                                          'Refunding') // Display a loading spinner when refunding
                                      : isRefund == true
                                          ? const Text(
                                              'Refunded') // Display 'Refunded' when refund is true
                                          : const SizedBox
                                              .shrink(), // Placeholder for no content
                            ),
                          SizedBox(
                            width: 10,
                          ),
                          TextButton(
                            onPressed: () {
                              if (isRefund == true || isRefunding == true) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Error'),
                                        content: Text(
                                            'You can\'t resell the package that already apply for refund.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    });
                              } else {
                                if (resaleQuantity + sold >=
                                    widget.travelPackagePurchased.quantity) {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: Text('Insufficient Quantity'),
                                        content: Text(
                                            'You do not have enough quantity to resell.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context)
                                                  .pop(); // Close the dialog
                                            },
                                            child: Text('OK'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                } else {
                                  _showResellDialog(context);
                                }
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                  255, 159, 118, 249), // Blue background color
                              foregroundColor: Colors
                                  .white, // Text color (white text on blue background)
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12), // Optional: adjust padding
                            ),
                            child: const Text('Resale'),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Own: ${widget.travelPackagePurchased.quantity}',
                              textAlign: TextAlign
                                  .left, // Optional: Align text to the center
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Reselling: ${resaleQuantity}',
                              textAlign: TextAlign
                                  .center, // Optional: Align text to the center
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Sold: ${sold}',
                              textAlign: TextAlign
                                  .right, // Optional: Align text to the center
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.travelPackagePurchased.quantity ==
                widget.travelPackagePurchased.soldQuantity ||
            widget.travelPackagePurchased.isRefund == true)
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
                  child: widget.travelPackagePurchased.isRefund
                      ? Text(
                          'Refunded',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      : Text(
                          'Not Available',
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
      ],
    );
  }

  void _showRefundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Refund'),
          content:
              const Text('Are you sure you want to proceed with the refund?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Proceed with the refund logic
                Navigator.of(context).pop(); // Close the dialog
                _processRefund(); // Call refund processing method
              },
              child: const Text('Refund'),
            ),
          ],
        );
      },
    );
  }

// Dummy function to handle refund processing
  void _processRefund() async {
    RefundPackageModel refundPackageModel = RefundPackageModel(
        id: '',
        travelPackagePurchasedId: widget.travelPackagePurchased.id,
        price: widget.travelPackagePurchased.price,
        createdBy: widget.currentUserId,
        createdAt: DateTime.now(),
        expiredDate: DateTime.now().add(Duration(days: 365 * 5)),
        travelCompanyId: travelPackage!.createdBy,
        travelPackageId: widget.travelPackagePurchased.travelPackageId,
        refundQuantity: widget.travelPackagePurchased.quantity);

    print(refundPackageModel.toString());
    try {
      await _firestoreService.insertDataWithAutoID(
          'Refund_Packages', refundPackageModel.toMap());
      await _firestoreService.updateSubCollectionField(
          collection: 'User',
          documentId: widget.currentUserId,
          subCollection: 'Travel_Packages_Purchased',
          subDocumentId: widget.travelPackagePurchased.id,
          field: 'is_refunding',
          value: true);
      setState(() {
        isRefunding = true;
      });
    } catch (e) {
      print(e);
    }
    print('Refund processed');
  }

  void _showResellDialog(BuildContext context) {
    // Create a controller for the price input field
    TextEditingController priceController = TextEditingController();
    final _formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Quantity Resell'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return FormBuilder(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(
                      height: 20,
                    ),
                    Text(
                      'Quantity: $quantity',
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: () {
                            setState(() {
                              if (quantity > 0) {
                                quantity--;
                              }
                            });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (quantity < resaleAvailable) {
                              setState(() {
                                quantity++;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    FormBuilderTextField(
                      name: 'price',
                      keyboardType:
                          TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Enter Price',
                        border: OutlineInputBorder(),
                      ),
                      validator: FormBuilderValidators.required(),
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (_formKey.currentState?.saveAndValidate() ?? false) {
                  final formValues = _formKey.currentState?.value;
                  double price = double.tryParse(
                          formValues?['price']?.toString() ?? '0') ??
                      0.0;
                  price = double.parse(
                      price.toStringAsFixed(2)); // Round to 2 decimal places

                  NewTravelPackageModel travelPackageResale =
                      NewTravelPackageModel(
                          id: '',
                          name: travelPackage!.name,
                          itinerary: travelPackage!.itinerary,
                          price: price,
                          startDate: travelPackage!.startDate,
                          endDate: travelPackage!.endDate,
                          quantity: quantity,
                          images: travelPackage!.images,
                          createdBy: travelPackage!.createdBy,
                          groupChatId: travelPackage!.groupChatId,
                          resellerId: widget.currentUserId,
                          isResale: true,
                          createdAt: DateTime.now(),
                          quantityAvailable: quantity,
                          ticketIdNumMap: travelPackage!.ticketIdNumMap,
                          travelPackageIdForResale: travelPackage!.id,
                          travelPackagePurchasedId:
                              widget.travelPackagePurchased.id);
                  try {
                    await _firestoreService.insertDataWithAutoID(
                        'New_Travel_Packages', travelPackageResale.toMap());

                    int newResaleQuantity = resaleQuantity + quantity;
                    await _firestoreService.updateSubCollectionField(
                        collection: "User",
                        documentId: widget.currentUserId,
                        subCollection: 'Travel_Packages_Purchased',
                        subDocumentId: widget.travelPackagePurchased.id,
                        field: 'resale_quantity',
                        value: newResaleQuantity);
                    setState(() {
                      resaleQuantity = newResaleQuantity;
                      resaleAvailable = widget.travelPackagePurchased.quantity -
                          resaleQuantity -
                          sold;
                      quantity = 0;
                    });
                  } catch (e) {}
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Successfully On Shelves')));
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
