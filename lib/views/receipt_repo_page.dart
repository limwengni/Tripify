import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/receipt_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/receipt_card_list.dart';
import 'package:tripify/widgets/travel_packages_on_shelves_card_list.dart';

class ReceiptRepoPage extends StatefulWidget {
  @override
  _ReceiptRepoPageState createState() => _ReceiptRepoPageState();
}

class _ReceiptRepoPageState extends State<ReceiptRepoPage> {
  // List to hold travel packages
  List<ReceiptModel> receiptList = [];
  FirestoreService firestoreService = FirestoreService();
  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchReceipt();
  }

  Future<void> fetchReceipt() async {
    try {
      List<Map<String, dynamic>>? data = await firestoreService
          .getSubCollectionData('User', currentUserId, 'Receipts');

      if (data != null) {
        if (mounted) {
          setState(() {
            receiptList =
                data.map((item) => ReceiptModel.fromMap(item)).toList();
            isLoading = false;
          });
        }
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print("Error fetching receipts: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
        'Receipt Repository',
      )),
      body: Center(
        child: isLoading
            ? CircularProgressIndicator(color: Color(0xFF9F76F9))
            : receiptList.isNotEmpty
                ? Column(
                    children: [
                      Expanded(
                        child: ReceiptCardList(
                          receiptList: receiptList,
                          currentUserId: currentUserId,
                        ),
                      ),
                    ],
                  )
                : Text('No Travel Package Found!'),
      ),
    );
  }
}
