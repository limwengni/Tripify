import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/ad_model.dart';

class AdProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add new Advertisement to Firebase
  Future<void> createAdvertisement(Advertisement ad, BuildContext context) async {
    try {
      // Add advertisement to the "Advertisement" collection
      await _db.collection('Advertisement').add(ad.toMap());

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Advertisement created successfully!',
            style: TextStyle(color: Colors.white)),
        backgroundColor: Color.fromARGB(255, 159, 118, 249),
      ));
    } catch (e) {
      print("Error creating advertisement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Failed to create advertisement.'),
            backgroundColor: Colors.red),
      );
    }
  }
}
