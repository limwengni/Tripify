import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/refund_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/refund_application_card_list.dart';
import 'package:tripify/widgets/travel_package_purchased_card_list.dart';

class RefundPage extends StatefulWidget {
  @override
  _RefundPageState createState() => _RefundPageState();
}

class _RefundPageState extends State<RefundPage> {
  // List to hold travel packages
  List<RefundPackageModel> refundPackagesList = [];
  FirestoreService firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true; // Flag for loading state

  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getStreamDataByField(
          collection: 'Refund_Packages',
          field: 'travel_company_id',
          value: currentUserId,
          
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

          List<RefundPackageModel> refundPackagesList = snapshot
              .data!.docs
              .map((doc) => RefundPackageModel.fromMap(
                  doc.data() as Map<String, dynamic>))
              .toList();
          return RefundApplicationCardList(
            refundPackagesList: refundPackagesList,
            currentUserId: currentUserId,
          );
        });
  }
}
