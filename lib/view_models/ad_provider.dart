import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/ad_model.dart';

class AdProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add new Advertisement to Firebase
  Future<void> createAdvertisement(
      Advertisement ad, BuildContext context) async {
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

  Future<void> updateAdStatus() async {
    try {
      // Get the current date
      DateTime currentDate = DateTime.now();

      // Fetch all ads from your database
      final adsSnapshot =
          await FirebaseFirestore.instance.collection('Advertisement').get();

      // Loop through each ad to check if it has expired
      for (var doc in adsSnapshot.docs) {
        DateTime endDate = doc['end_date'].toDate();
        if (endDate.isBefore(currentDate)) {
          await FirebaseFirestore.instance
              .collection('Advertisement')
              .doc(doc.id)
              .update({
            'status': 'ended',
          });
        }
      }
    } catch (e) {
      print("Error updating ad status: $e");
    }
  }

  Future<List<Map<String, dynamic>>> getAdDetails(
      String travelPackageId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Advertisement')
          .where('package_id', isEqualTo: travelPackageId)
          .get();

      if (querySnapshot.docs.isEmpty) {
        return [];
      }

      List<Map<String, dynamic>> adDetails = [];

      // Loop through the docs and extract id and status
      for (var doc in querySnapshot.docs) {
        adDetails.add({
          'id': doc.id,
          'status':
              doc['status'], 
        });
      }

      return adDetails;
    } catch (e) {
      print("Error fetching ad details: $e");
      return [];
    }
  }
}
