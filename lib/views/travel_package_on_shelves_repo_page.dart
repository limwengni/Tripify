import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/travel_packages_on_shelves_card_list.dart';

class TravelPackageOnShelvesRepoPage extends StatefulWidget {
  @override
  _TravelPackageOnShelvesRepoPageState createState() =>
      _TravelPackageOnShelvesRepoPageState();
}

class _TravelPackageOnShelvesRepoPageState
    extends State<TravelPackageOnShelvesRepoPage> {
      FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Travel Packages On Shelves"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getStreamDataByTwoField(
          collection: 'Travel_Packages',
          field: 'created_by',
          value: currentUserId,
          field2: 'is_resale',
          value2: false,
          orderBy: 'created_at', // Assuming you have a `created_at` field
          descending: true,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text("No travel packages found on shelves."),
            );
          }

          List<TravelPackageModel> travelPackagesOnShelvesList = snapshot.data!.docs
              .map((doc) => TravelPackageModel.fromMap(
                  doc.data() as Map<String, dynamic>))
              .toList();

          return TravelPackageOnShelvesCardList(
            travelPackagesOnShelvesList: travelPackagesOnShelvesList,
            currentUserId: currentUserId,
          );
        },
      ),
    );
  }
}
