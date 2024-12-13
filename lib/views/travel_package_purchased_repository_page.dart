import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/travel_package_purchased_card_list.dart';

class TravelPackagePurchasedRepositoryPage extends StatefulWidget {
  @override
  _TravelPackagePurchasedRepositoryPageState createState() =>
      _TravelPackagePurchasedRepositoryPageState();
}

class _TravelPackagePurchasedRepositoryPageState
    extends State<TravelPackagePurchasedRepositoryPage> {
  // List to hold travel packages
  List<TravelPackagePurchasedModel> travelPackagesPurchasedList = [];
  FirestoreService firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true; // Flag for loading state

  @override
  void initState() {
    super.initState();
    fetchTravelPackagesPurchased();
  }

  // Fetch purchased travel packages from Firestore
  Future<void> fetchTravelPackagesPurchased() async {
    try {
      List<Map<String, dynamic>>? data =
          await firestoreService.getSubCollectionData(
        'User',
        currentUserId,
        'Travel_Packages_Purchased',
      );

      if (mounted) {
        setState(() {
          if (data == null || data.isEmpty) {
          } else {
            travelPackagesPurchasedList = data
                .map((item) => TravelPackagePurchasedModel.fromMap(item))
                .toList();
          }
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
      print('Error fetching travel packages: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Purchased Travel Packages"),
      ),
      body: Center(
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                    color: Color(
                        0xFF9F76F9))) // Show loading spinner while fetching
            : travelPackagesPurchasedList == null ||
                    travelPackagesPurchasedList.isEmpty
                ? Text(
                    "No purchased travel packages found.") // Show message if no data
                : TravelPackagePurchasedCardList(
                    travelPackagesPurchasedList: travelPackagesPurchasedList!,
                    currentUserId: currentUserId,
                  ),
      ),
    );
  }
}
