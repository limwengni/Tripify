import 'dart:async';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/ad_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/ad_provider.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/new_travel_package_details_page.dart';
import 'package:tripify/views/renew_ads_page.dart';
import 'package:tripify/views/travel_package_details_page.dart';
import 'package:tripify/views/create_ads_page.dart';
import 'package:tripify/views/ad_wallet_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/views/view_ad_perf.dart';

class TravelPackageOnShelvesCard extends StatefulWidget {
  final NewTravelPackageModel travelPackageOnShelve;
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
  NewTravelPackageModel? travelPackage;
  bool showMore = false; // State to control visibility of the last row
  int? viewNum;
  int? clickNum;
  int? saveNum;
  double? purchaseRate;
  UserModel? travelCompanyUser;

  bool _hasAds = false;
  bool _isAdEnded = false;
  bool _isAdPaused = false;
  TextButton? actionButton;
  List<Map<String, dynamic>> _adDetails = [];
  String _adId = '';
  String _status = '';
  String _renewalType = '';
  bool walletActivated = false;
  bool _isEligible = false;
  Timer? _adStatusTimer;

  String? _selectedAdType;
  int _totalPrice = 0;
  int adsCredit = 0;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isRenewalInProgress = false;

  AdProvider adProvider = new AdProvider();

  final Map<String, Map<String, dynamic>> _adPackages = {
    "3 Days": {
      "duration": 3,
      "price": 50,
      "estimatedClicks": 100,
      "estimatedImpressions": 1000,
      "flatRate": 50.0,
    },
    "7 Days": {
      "duration": 7,
      "price": 100,
      "estimatedClicks": 200,
      "estimatedImpressions": 2000,
      "flatRate": 100.0,
    },
    "1 Month": {
      "duration": 30,
      "price": 300,
      "estimatedClicks": 600,
      "estimatedImpressions": 6000,
      "flatRate": 300.0,
    },
  };

  @override
  void initState() {
    travelPackage = widget.travelPackageOnShelve;
    fetchTravelCompany();
    super.initState();
    _startAdStatusTimer();
    checkIfAds(travelPackage!.id);
    _fetchWalletStatus();
  }

  Future<void> _renewAdAutomatically() async {
    try {
      // Fetch the current advertisement details
      var adDoc = await FirebaseFirestore.instance
          .collection('Advertisement')
          .doc(_adId)
          .get();

      if (adDoc.exists) {
        // Get the old ad data
        var adData = adDoc.data() as Map<String, dynamic>;
        DateTime oldCreatedAt = adData['created_at'].toDate();
        DateTime oldEndDate = adData['end_date'].toDate();
        String oldAdType = adData['ad_type'];

        // Calculate new start and end date
        DateTime newStartDate =
            DateTime.now(); // Start from now for the renewal
        int durationDays = 0;

        // Set duration days based on the ad type
        if (oldAdType == '3 Days') {
          durationDays = 3;
        } else if (oldAdType == '7 Days') {
          durationDays = 7;
        } else if (oldAdType == '1 Month') {
          durationDays = 30; // Adjust this as needed
        }

        DateTime newEndDate = newStartDate.add(Duration(days: durationDays));

        // Get the current user's ads credit
        String currentUserId = FirebaseAuth.instance.currentUser!.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(currentUserId)
            .get();

        int adsCredit = userDoc['ads_credit'] ?? 0;

        double _totalPrice = _calculateTotalPrice(adData);

        // Check if the user's ads credit is enough
        if (adsCredit >= _totalPrice) {
          // Create a new Advertisement object with updated values
          Advertisement updatedAd = Advertisement(
            id: _adId,
            packageId: widget.travelPackageOnShelve.id,
            adType: oldAdType, // Keep the same ad type
            startDate: newStartDate,
            endDate: newEndDate,
            status: 'ongoing',
            renewalType: 'automatic', // Keep the renewal type as 'automatic'
            createdAt: oldCreatedAt, // Keep the same created_at date
            cpcRate: adData['cpc_rate'],
            cpmRate: adData['cpm_rate'],
            flatRate: adData['flat_rate'],
          );

          // Proceed with the renewal process
          await AdProvider().renewAdvertisement(
            _adId,
            updatedAd,
            _totalPrice.toInt(),
            context,
          );

          // Update the user's ads credit after the renewal
          await FirebaseFirestore.instance
              .collection('User')
              .doc(currentUserId)
              .update({
            'ads_credit':
                adsCredit - _totalPrice, // Deduct the price from their credit
          });

          // Notify the user about the successful renewal
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Advertisement renewed successfully!'),
              backgroundColor: Color.fromARGB(255, 159, 118, 249),
            ),
          );

          Navigator.pop(context);
          Navigator.pop(context, true);
        } else {
          // If the user doesn't have enough credit, show an alert
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('You don\'t have enough ads credit to renew the ad.'),
              backgroundColor: Colors.red,
            ),
          );
          setState(() {
            _isRenewalInProgress = false;
          });
        }
      } else {
        // Handle the case where the advertisement doesn't exist
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Advertisement not found for renewal.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isRenewalInProgress = false;
        });
      }
    } catch (e) {
      // Handle any errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('An error occurred during automatic renewal.'),
          backgroundColor: Colors.red,
        ),
      );
      setState(() {
        _isRenewalInProgress = false;
      });
    }
  }

  double _calculateTotalPrice(Map<String, dynamic> adData) {
    double price = 0.0;
    String adType = adData['ad_type'];

    if (adType == '3 Days') {
      price = 50.0;
    } else if (adType == '7 Days') {
      price = 100.0;
    } else if (adType == '1 Month') {
      price = 300.0;
    }

    return price;
  }

  void _startAdStatusTimer() {
    _adStatusTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      checkIfAds(travelPackage!.id);

      print("Ad Status - isAdEnded: $_isAdEnded, Renewal Type: $_renewalType");

      // if (_isAdEnded && _renewalType == 'automatic' && !_isRenewalInProgress) {
      //   _isRenewalInProgress = true;
      //   _renewAdAutomatically();
      // }
    });
  }

  void dispose() {
    // Always cancel the timer when the widget is disposed to avoid memory leaks
    _adStatusTimer?.cancel();
    super.dispose();
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

  Future<void> _fetchWalletStatus() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('User')
        .doc(currentUserId)
        .get();

    if (userDoc.exists) {
      setState(() {
        walletActivated = userDoc['wallet_activated'] ?? false;
      });
    } else {
      setState(() {
        walletActivated = false;
      });
    }
  }

  Future<void> checkAdEligibility(String packageId) async {
    bool isEligible = await adProvider.checkAdEligibility(packageId);

    setState(() {
      _isEligible = isEligible;
    });

    print("eligible: $_isEligible");
  }

  Future<bool> checkIfAds(String travelPackageId) async {
    // Fetch the ad details using your provider
    List<Map<String, dynamic>> adDetails =
        await adProvider.getAdDetails(travelPackageId);

    // Initialize the status variable
    String adId = '';
    String status = '';
    String renewalType = '';

    // Check if there are ads available
    if (adDetails.isNotEmpty) {
      _hasAds = true;

      // Loop through the fetched ad details
      for (var ad in adDetails) {
        adId = ad['id']; // Get the ad ID
        status = ad['status']; // Get the status of the ad
        renewalType = ad['renewal_type']; // Get renewal type
      }

      updateAdStatus();

      // Update the state with the final status
      setState(() {
        _adId = adId;
        _status = status;
        if (_hasAds && _status == 'ended') {
          _isAdEnded = true;
        } else if (_hasAds && _status == 'paused') {
          _isAdEnded = false;
          _isAdPaused = true;
        } else {
          _isAdEnded = false;
          _isAdPaused = false;
        }
        _renewalType = renewalType;
      });
    } else {
      _hasAds = false;

      // If no ads, then check if that package can create ads or not
      await checkAdEligibility(travelPackageId);
      print("No ads available for this travel package.");
    }

    return _hasAds;
  }

  void updateAdStatus() async {
    await adProvider.updateAdStatus();
  }

  void _showPausedAdDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ad Paused'),
          content: Text(
              'This ad is paused due to stock running out. You can still view its performance data.'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewAdsPerformancePage(adId: _adId, paused: true),
                  ),
                );
              },
              child: Text('View Performance'),
            ),
          ],
        );
      },
    );
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
    return Stack(children: [
      GestureDetector(
          onTap: () {
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
                            if (_hasAds) ...[
                              if (!_isAdEnded) ...[
                                TextButton(
                                  onPressed: () {
                                    if (_isAdPaused) {
                                      // Show alert dialog if the ad is paused
                                      _showPausedAdDialog(context);
                                    } else {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                ViewAdsPerformancePage(
                                                    adId: _adId, paused: false),
                                          ));
                                    }
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                  ),
                                  child: const Text('View Ads Performance'),
                                ),
                              ] else if (_isAdEnded &&
                                  _renewalType == 'manual') ...[
                                TextButton(
                                  onPressed: () async {
                                    // Logic to renew the ad

                                    String currentUserId =
                                        FirebaseAuth.instance.currentUser!.uid;

                                    // Check the wallet status before proceeding
                                    DocumentSnapshot userDoc =
                                        await FirebaseFirestore.instance
                                            .collection('User')
                                            .doc(currentUserId)
                                            .get();

                                    adsCredit = userDoc['ads_credit'] ?? 0;

                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => RenewAdsPage(
                                            adId: _adId,
                                            travelPackageId:
                                                widget.travelPackageOnShelve.id,
                                            adsCredit: adsCredit,
                                          ),
                                        ));
                                  },
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.orange,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 12),
                                  ),
                                  child: const Text('Renew Ads'),
                                ),
                              ]
                            ] else if (_isEligible) ...[
                              TextButton(
                                onPressed: () async {
                                  String currentUserId =
                                      FirebaseAuth.instance.currentUser!.uid;

                                  // Check the wallet status before proceeding
                                  DocumentSnapshot userDoc =
                                      await FirebaseFirestore.instance
                                          .collection('User')
                                          .doc(currentUserId)
                                          .get();

                                  if (!walletActivated) {
                                    adsCredit = userDoc['ads_credit'] ?? 0;

                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Activate Wallet'),
                                        content: Text(
                                            'You need to activate your wallet to use ads credits and buy ads.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () async {
                                              Navigator.pop(context);

                                              final bool? result =
                                                  await Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      WalletPage(
                                                          walletBalance: 0),
                                                ),
                                              );

                                              if (result != null && result) {
                                                setState(() {
                                                  walletActivated = true;
                                                });
                                              }
                                            },
                                            child: Text('Activate Wallet'),
                                          ),
                                        ],
                                      ),
                                    );
                                  } else {
                                    String id = widget.travelPackageOnShelve.id;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CreateAdsPage(
                                          travelPackageId: id,
                                          adsCredit: userDoc['ads_credit'] ?? 0,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: TextButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                                child: const Text('Create Ads'),
                              )
                            ],
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
              ))),
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
        ),
    ]);
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
                    'New_Travel_Packages', widget.travelPackageOnShelve.id);
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
