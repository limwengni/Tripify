import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/ad_provider.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/travel_package_details_page.dart';
import 'package:tripify/views/create_ads_page.dart';

class TravelPackageOnShelvesCard extends StatefulWidget {
  final TravelPackageModel travelPackageOnShelve;
  final String currentUserId;

  const TravelPackageOnShelvesCard(
      {super.key,
      required this.travelPackageOnShelve,
      required this.currentUserId});

  @override
  _TravelPackagePurchasedCardState createState() =>
      _TravelPackagePurchasedCardState();
}

class _TravelPackagePurchasedCardState
    extends State<TravelPackageOnShelvesCard> {
  FirestoreService _firestoreService = FirestoreService();
  TravelPackageModel? travelPackage;
  bool showMore = false; // State to control visibility of the last row
  int? viewNum;
  int? clickNum;
  int? saveNum;
  double? purchaseRate;
  UserModel? travelCompanyUser;

  bool _hasAds = false;
  TextButton? actionButton;
  List<Map<String, dynamic>> _adDetails = [];
  String _status = '';

  AdProvider adProvider = new AdProvider();

  @override
  void initState() {
    travelPackage = widget.travelPackageOnShelve;
    fetchTravelCompany();
    super.initState();
    checkIfAds(travelPackage!.id);
    updateAdStatus();
  }

  void fetchTravelCompany() async {
    Map<String, dynamic>? userMap;
    userMap = await _firestoreService.getDataById(
        'User', widget.travelPackageOnShelve.createdBy);

    setState(() {
      if (userMap != null) {
        travelCompanyUser = UserModel.fromMap(userMap, userMap['id']);
        print(travelCompanyUser);
      }
    });
  }

  Future<bool> checkIfAds(String travelPackageId) async {
    // Fetch the ad details using your provider
    List<Map<String, dynamic>> adDetails =
        await adProvider.getAdDetails(travelPackageId);

    // Print the ad details for debugging
    print("Ad details: $adDetails");

    // Initialize the status variable
    String status = '';

    // Check if there are ads available
    if (adDetails.isNotEmpty) {
      _hasAds = true;

      // Loop through the fetched ad details
      for (var ad in adDetails) {
        String adId = ad['id']; // Get the ad ID
        status = ad['status']; // Get the status of the ad
      }

      print("Ad status: $status");
    } else {
      _hasAds = false;
      print("No ads available for this travel package.");
    }

    // Update the state with the final status
    setState(() {
      _status = status;
      print("Updated status: $_status");
    });

    return _hasAds;
  }

  void updateAdStatus() async {
    await adProvider.updateAdStatus();
  }

  @override
  Widget build(BuildContext context) {
    viewNum = widget.travelPackageOnShelve.viewNum?.length;
    clickNum = widget.travelPackageOnShelve.clickNum?.length;
    saveNum = widget.travelPackageOnShelve.saveNum?.length;

    double ctr = clickNum != null && viewNum != null && viewNum != 0
        ? clickNum! / viewNum!
        : 0;

    if (clickNum != null) {
      purchaseRate = (widget.travelPackageOnShelve.quantity -
              widget.travelPackageOnShelve.quantityAvailable) /
          clickNum!;
      purchaseRate = double.parse(purchaseRate!.toStringAsFixed(2));
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: widget.travelPackageOnShelve.isAvailable
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TravelPackageDetailsPage(
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
                            Positioned.fill(
                              child: Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                ),
                              ),
                            ),
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
                            'RM ${widget.travelPackageOnShelve.price}',
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(
                            'Resell Quantity: ${widget.travelPackageOnShelve.quantity}',
                            style: const TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          Icon(Icons.remove_red_eye),
                          SizedBox(
                            width: 5,
                          ),
                          Text(viewNum != null ? '$viewNum' : '0'),
                          Spacer(),

                          // Ads button (later need to change..)
                          TextButton(
                            onPressed: () {
                              String id = widget.travelPackageOnShelve.id;

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateAdsPage(travelPackageId: id),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                            child: const Text('Create Ads'),
                          ),
                          const SizedBox(width: 8),

                          // Delete button
                          TextButton(
                            onPressed: () {
                              if (widget.travelPackageOnShelve.quantity !=
                                  widget.travelPackageOnShelve
                                      .quantityAvailable) {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text('Error'),
                                      content: const Text(
                                          'You delete the travel package that already have user purchased!'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context)
                                                .pop(); // Close the dialog
                                          },
                                          child: const Text('OK'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              } else {
                                _showDeleteDialog(context);
                              }
                            },
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  vertical: 8, horizontal: 12),
                            ),
                            child: Text('Delete'),
                          )
                        ],
                      ),
                      Visibility(
                          visible:
                              showMore, // Show row only if `showMore` is true
                          child: Table(
                            columnWidths: const {
                              0: FlexColumnWidth(
                                  1), // Own column takes 1/3 of the width
                              1: FlexColumnWidth(
                                  1), // Available column takes 1/3 of the width
                              2: FlexColumnWidth(
                                  1), // Sold column takes 1/3 of the width
                            },
                            border: TableBorder(
                              top: BorderSide(color: Colors.grey, width: 0.5),
                              left: BorderSide.none,
                              right: BorderSide.none,
                              horizontalInside: BorderSide
                                  .none, // For no borders between rows
                              verticalInside: BorderSide
                                  .none, // For no borders between columns
                            ),
                            children: [
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Own: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Bold for "Sold:"
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${widget.travelPackageOnShelve.quantity}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .normal, // Normal for the number
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          const TextSpan(
                                            text: 'Available: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Bold for "Sold:"
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${widget.travelPackageOnShelve.quantityAvailable}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .normal, // Normal for the number
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Sold: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Bold for "Sold:"
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '${widget.travelPackageOnShelve.quantity - widget.travelPackageOnShelve.quantityAvailable}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .normal, // Normal for the number
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              TableRow(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'CTR: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Bold for "Sold:"
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '${ctr}%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .normal, // Normal for the number
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'PR: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Bold for "Sold:"
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text: purchaseRate != null
                                                ? '${purchaseRate}%'
                                                : '0%',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .normal, // Normal for the number
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: RichText(
                                      textAlign: TextAlign.center,
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: 'Save: ',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .bold, // Bold for "Sold:"
                                              color: Colors.grey,
                                            ),
                                          ),
                                          TextSpan(
                                            text: saveNum != null
                                                ? '${saveNum}'
                                                : '0',
                                            style: const TextStyle(
                                              fontWeight: FontWeight
                                                  .normal, // Normal for the number
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          )),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            showMore = !showMore; // Toggle `showMore` state
                          });
                        },
                        child: Text(showMore ? 'Show Less' : 'Show More'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!widget.travelPackageOnShelve.isAvailable)
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
<<<<<<< HEAD
          ),
      ],
=======
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
                        'RM ' + travelPackage!.price.toString(),
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        'Resell Quantity: ${widget.travelPackageOnShelve.quantity}',
                        style: const TextStyle(
                          fontWeight: FontWeight.normal,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.remove_red_eye),
                      SizedBox(
                        width: 5,
                      ),
                      Text(viewNum != null ? '$viewNum' : '0'),
                      Spacer(),
                      if (_hasAds && _status == 'running') ...[
                        TextButton(
                          onPressed: () {
                            // Logic to view ads performance
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                          ),
                          child: const Text('View Ads Performance'),
                        ),
                      ] else if (_status == 'ended') ...[
                        TextButton(
                          onPressed: () {
                            // Logic to renew the ad
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                          ),
                          child: const Text('Renew Ads'),
                        ),
                      ] else ...[
                        TextButton(
                          onPressed: () {
                            String id = widget.travelPackageOnShelve.id;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    CreateAdsPage(travelPackageId: id),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 12),
                          ),
                          child: const Text('Create Ads'),
                        ),
                      ],
                      const SizedBox(width: 8),

                      // Delete button
                      TextButton(
                        onPressed: () {
                          if (widget.travelPackageOnShelve.quantity !=
                              widget.travelPackageOnShelve.quantityAvailable) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Error'),
                                  content: const Text(
                                      'You delete the travel package that already have user purchased!'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the dialog
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            _showDeleteDialog(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 8, horizontal: 12),
                        ),
                        child: const Text('Delete'),
                      )
                    ],
                  ),
                  Visibility(
                      visible: showMore, // Show row only if `showMore` is true
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(
                              1), // Own column takes 1/3 of the width
                          1: FlexColumnWidth(
                              1), // Available column takes 1/3 of the width
                          2: FlexColumnWidth(
                              1), // Sold column takes 1/3 of the width
                        },
                        border: TableBorder(
                          top: BorderSide(color: Colors.grey, width: 0.5),
                          left: BorderSide.none,
                          right: BorderSide.none,
                          horizontalInside:
                              BorderSide.none, // For no borders between rows
                          verticalInside:
                              BorderSide.none, // For no borders between columns
                        ),
                        children: [
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Own: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Bold for "Sold:"
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${widget.travelPackageOnShelve.quantity}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .normal, // Normal for the number
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Available: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Bold for "Sold:"
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${widget.travelPackageOnShelve.quantityAvailable}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .normal, // Normal for the number
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Sold: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Bold for "Sold:"
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text:
                                            '${widget.travelPackageOnShelve.quantity - widget.travelPackageOnShelve.quantityAvailable}',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .normal, // Normal for the number
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          TableRow(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'CTR: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Bold for "Sold:"
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text: '${ctr}%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .normal, // Normal for the number
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'PR: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Bold for "Sold:"
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text: purchaseRate != null
                                            ? '${purchaseRate}%'
                                            : '0%',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .normal, // Normal for the number
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: RichText(
                                  textAlign: TextAlign.center,
                                  text: TextSpan(
                                    children: [
                                      TextSpan(
                                        text: 'Save: ',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .bold, // Bold for "Sold:"
                                          color: Colors.grey,
                                        ),
                                      ),
                                      TextSpan(
                                        text: saveNum != null
                                            ? '${saveNum}'
                                            : '0',
                                        style: const TextStyle(
                                          fontWeight: FontWeight
                                              .normal, // Normal for the number
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      )),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        showMore = !showMore; // Toggle `showMore` state
                      });
                    },
                    child: Text(showMore ? 'Show Less' : 'Show More'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
>>>>>>> 1e58e89069e0a93551e606c2db094f99ee8d5d53
    );
  }

  void _showDeleteDialog(BuildContext context) {
    TextEditingController priceController = TextEditingController();
    final _formKey = GlobalKey<FormBuilderState>();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
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
                      'Are you sure to delete ${widget.travelPackageOnShelve.name} Travel Package?',
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () async {
<<<<<<< HEAD
=======
                await _firestoreService.deleteData(
                    'Travel_Packages', widget.travelPackageOnShelve.id);
>>>>>>> 1e58e89069e0a93551e606c2db094f99ee8d5d53
                if (widget.travelPackageOnShelve.isResale == true) {
                  await _firestoreService.incrementFieldInSubCollection(
                      'User',
                      widget.currentUserId,
                      'Travel_Packages_Purchased',
                      widget.travelPackageOnShelve.travelPackagePurchasedId!,
                      -widget.travelPackageOnShelve.quantityAvailable,
                      'resale_quantity');

                  print(widget.travelPackageOnShelve.quantityAvailable);
                } else {
                  await _firestoreService.deleteData('Conversations',
                      widget.travelPackageOnShelve.groupChatId!);
                }

                await _firestoreService.deleteData(
                    'Travel_Packages', widget.travelPackageOnShelve.id);
                Navigator.of(context).pop();
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
