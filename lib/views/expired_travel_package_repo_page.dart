import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/travel_package_car_list.dart';

class ExpiredTravelPackageRepoPage extends StatefulWidget {
  @override
  _ExpiredTravelPackageRepoPageState createState() =>
      _ExpiredTravelPackageRepoPageState();
}

class _ExpiredTravelPackageRepoPageState
    extends State<ExpiredTravelPackageRepoPage> {
  FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool _isLoading = true;

  List<NewTravelPackageModel> expiredTravelPackages = [];

  @override
  void initState() {
    super.initState();
    _fetchExpiredPackages();
  }

  Future<void> _fetchExpiredPackages() async {
    await fetchExpiredTravelPackages();
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> fetchExpiredTravelPackages() async {
    // Fetch purchased travel packages for the current user
    List<Map<String, dynamic>>? purchasedPackagesData =
        await _firestoreService.getSubCollectionData(
      'User',
      currentUserId,
      'Travel_Packages_Purchased',
    );

    if (purchasedPackagesData != null && purchasedPackagesData.isNotEmpty) {
      List<NewTravelPackageModel> expiredPackages = [];

      for (var data in purchasedPackagesData) {
        String packageId = data['travel_package_id'];

        // Fetch the corresponding travel package from New_Travel_Packages collection
        DocumentSnapshot packageDoc = await FirebaseFirestore.instance
            .collection('New_Travel_Packages')
            .doc(packageId)
            .get();

        if (packageDoc.exists) {
          Map<String, dynamic> packageData =
              packageDoc.data() as Map<String, dynamic>;

          // Check if the package has expired
          Timestamp endDateTimestamp = packageData['end_date'];
          DateTime endDate = endDateTimestamp.toDate();
          DateTime currentDate = DateTime.now();

          if (endDate.isBefore(currentDate)) {
            // Package is expired
            expiredPackages.add(NewTravelPackageModel.fromMap(packageData));
          }
        }
      }

      // Update the state with expired packages
      if (mounted) {
        setState(() {
          expiredTravelPackages = expiredPackages;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Expired Travel Packages"),
        ),
        body: Center(
            child: expiredTravelPackages.isEmpty
                ? Text("No purchased travel packages found.")
                : TravelPackageCardList(
                    travelPackagesList: expiredTravelPackages,
                    currentUserId: currentUserId,
                  )));
  }
}
