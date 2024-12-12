import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/models/refund_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/cashout_card_list.dart';
import 'package:tripify/widgets/cashout_process_card_list.dart';
import 'package:tripify/widgets/refund_application_card_list.dart';
import 'package:tripify/widgets/travel_package_purchased_card_list.dart';

class CashourProcessPage extends StatefulWidget {
  @override
  _CashourProcessPageState createState() =>_CashourProcessPageState();
}

class _CashourProcessPageState extends State<CashourProcessPage> {
  // List to hold travel packages
  List<CashoutApplicationModel> cashoutApplicationList = [];
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
        stream: firestoreService.getStreamData(
          collection: 'Cashout_Applications',   
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

          List<CashoutApplicationModel> cashoutApplicationList = snapshot
              .data!.docs
              .map((doc) => CashoutApplicationModel.fromMap(
                  doc.data() as Map<String, dynamic>))
              .toList();
          return CashoutProcessCardList(
            cashoutList: cashoutApplicationList,
            
          );
        });
  }
}
