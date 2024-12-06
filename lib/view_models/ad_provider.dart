import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/ad_model.dart';
import 'package:tripify/models/ad_report_model.dart';

class AdProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add new Advertisement to Firebase
  Future<void> createAdvertisement(
      Advertisement ad, BuildContext context) async {
    try {
      // Add advertisement to the "Advertisement" collection
      DocumentReference adRef =
          await _db.collection('Advertisement').add(ad.toMap());

      AdReport adReport = AdReport(
        adId: adRef.id,
        reportDate: DateTime.now(),
        clickCount: 0,
        engagementRate: 0.0,
        successRate: 0.0,
        reach: 0,
        cost: 0.0,
        cpc: 0.0,
        revenue: 0.0,
        roas: 0.0,
      );

      await _db.collection('AdReport').add(adReport.toMap());

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
          'status': doc['status'],
        });
      }

      return adDetails;
    } catch (e) {
      print("Error fetching ad details: $e");
      return [];
    }
  }

  // Ad Report
  Future<void> updateAdReport(String adId, int clickCount) async {
    try {
      var adReportRef =
          _db.collection('AdReport').where('ad_id', isEqualTo: adId).limit(1);

      var snapshot = await adReportRef.get();
      if (snapshot.docs.isNotEmpty) {
        var reportDoc = snapshot.docs.first;
        await reportDoc.reference.update({
          'click_ount': clickCount,
          // Update other fields as necessary
        });
      }
    } catch (e) {
      print("Error updating ad report: $e");
    }
  }
}
