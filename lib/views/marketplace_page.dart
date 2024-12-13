import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/travel_package_car_list.dart';
import 'package:tripify/widgets/travel_package_card.dart';

class MarketplacePage extends StatefulWidget {
  @override
  _MarketplacePageState createState() => _MarketplacePageState();
}

class _MarketplacePageState extends State<MarketplacePage> {
  // List to hold travel packages
  List<NewTravelPackageModel> travelPackagesList = [];
  FirestoreService firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  void initState() {
    super.initState();
    fetchTravelPackages();
  }

  Future<void> fetchTravelPackages() async {
    List<Map<String, dynamic>> data =
        await firestoreService.getDataOrderBy('New_Travel_Packages','created_at',true);

    // Parse the data into your model
    if (mounted) {
      setState(() {
        travelPackagesList =
            data.map((item) => NewTravelPackageModel.fromMap(item)).toList();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: travelPackagesList!= null
          ? Column(
              children: [
                Expanded(
                  child: TravelPackageCardList(
                    travelPackagesList: travelPackagesList,
                    currentUserId: currentUserId,
                  ),
                ),
              ],
            )
          : Text('No Travel Package Found!'),
    );
  }
}
