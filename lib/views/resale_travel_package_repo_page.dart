import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/travel_packages_on_shelves_card_list.dart';

class ResaleTravelPackageRepoPage extends StatefulWidget {
  @override
  _ResaleTravelPackageRepoPageState createState() =>
      _ResaleTravelPackageRepoPageState();
}

class _ResaleTravelPackageRepoPageState
    extends State<ResaleTravelPackageRepoPage> {
      FirestoreService _firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resale Travel Packages"),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestoreService.getStreamDataByField(
          collection: 'New_Travel_Packages',
          field: 'reseller_id',
          value: currentUserId,
          orderBy: 'created_at', 
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
              child: Text("No travel packages found resell."),
            );
          }

          List<NewTravelPackageModel> travelPackagesOnShelvesList = snapshot.data!.docs
              .map((doc) => NewTravelPackageModel.fromMap(
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
