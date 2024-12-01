import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart'; // Import shimmer package
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
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
  UserModel? user;
  bool userLoaded = false;
  TravelPackageModel? travelPackage;
  int quantity = 1;
  int resaleQuantity = 0;
  TravelPackageModel? travelPackageResale;

  @override
  void initState() {
    super.initState();
    fetchTravelPackageAndTravelCompany();
  }

  void fetchTravelPackageAndTravelCompany() async {
    Map<String, dynamic>? travelPackageMap;
    travelPackageMap = await _firestoreService.getDataById(
        'Travel_Packages', widget.travelPackagePurchased.travelPackageId);
    List<Map<String, dynamic>>? travelPackageResaleMapList;

    if (travelPackageMap != null) {
      travelPackageResaleMapList = await _firestoreService.getDataByTwoFields(
          'Travel_Packages',
          'reseller_id',
          widget.currentUserId,
          'travel_package_id_for_resale',
          widget.travelPackagePurchased.id);
      if (travelPackageResaleMapList.isEmpty) {
        for (int i = 0; i < travelPackageResaleMapList.length; i++) {
          travelPackageResale =
              TravelPackageModel.fromMap(travelPackageResaleMapList[i]);
          resaleQuantity = resaleQuantity + travelPackageResale!.quantity;
        }
      }
      setState(() {
        travelPackage = TravelPackageModel.fromMap(travelPackageMap!);
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
          user = UserModel.fromMap(userMap, userMap['id']);
          userLoaded = true;
        });
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    if (!userLoaded || travelPackage == null) {
      return Center(child: CircularProgressIndicator());
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TravelPackageDetailsPage(
              travelPackage: travelPackage!,currentUserId: widget.currentUserId,
            ),
          ),
        );
      },
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
                          loadingBuilder: (context, child, loadingProgress) {
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
                          errorBuilder: (context, error, stackTrace) => Icon(
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
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                                '${DateFormat('yyyy-MM-dd').format(travelPackage!.startDate)} - ${DateFormat('yyyy-MM-dd').format(travelPackage!.endDate)}'),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                      Text(
                        travelPackage!.price.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      user != null
                          ? Container(
                              child: CircleAvatar(
                                radius: 15,
                                backgroundImage: NetworkImage(user!.profilePic),
                                backgroundColor: Colors.grey[200],
                              ),
                            )
                          : Text('loading'),
                      const SizedBox(width: 10),
                      Text(user!.username),
                      SizedBox(
                        width: 10,
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          if (resaleQuantity >=
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
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.blue, // Blue background color
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
                          'Sold: ${widget.travelPackagePurchased.soldQuantity}',
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
    );
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
                            if (quantity <
                                widget.travelPackagePurchased.quantity) {
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

                  TravelPackageModel travelPackageResale = TravelPackageModel(
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
                      quantityAvailable:quantity);
                  try {
                    await _firestoreService.insertDataWithAutoID(
                        'Travel_Packages', travelPackageResale.toMap());

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
