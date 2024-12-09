import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/ad_model.dart';
import 'package:tripify/models/ad_report_model.dart';

class AdProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add new Advertisement to Firebase
  Future<void> createAdvertisement(
      Advertisement ad, BuildContext context, int adCost) async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;
      DocumentSnapshot userDoc =
          await _db.collection('User').doc(currentUserId).get();

      if (userDoc.exists) {
        int currentAdsCredit = userDoc['ads_credit'] ?? 0;

        if (currentAdsCredit < adCost) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Insufficient ads credit to create the ad.'),
            backgroundColor: Colors.red,
          ));
          return;
        }

        WriteBatch batch = FirebaseFirestore.instance.batch();

        DocumentReference adRef = _db.collection('Advertisement').doc();
        batch.set(adRef, ad.toMap());

        DateTime now = DateTime.now();
        String transactionType = 'adspurchase';

        batch.set(
          FirebaseFirestore.instance.collection('AdsCredTransaction').doc(),
          {
            'user_id': currentUserId,
            'amount': adCost,
            'created_at': now,
            'type': 'adspurchase',
          },
        );

        AdReport adReport = AdReport(
          adId: adRef.id,
          reportDate: DateTime.now(),
          clickCount: 0,
          engagementRate: 0.0,
          successRate: 0.0,
          reach: 0,
          cpc: 0.0,
          cpm: 0.0,
          flatRate: adCost.toDouble(),
          revenue: 0.0,
          roas: 0.0,
        );

        batch.set(_db.collection('AdReport').doc(), adReport.toMap());

        int newAdsCredit = currentAdsCredit - adCost;

        batch.update(_db.collection('User').doc(currentUserId), {
          'ads_credit': newAdsCredit,
        });

        await batch.commit();

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Advertisement created successfully!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 159, 118, 249),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to create advertisement.'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Error creating advertisement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text('An error occurred while creating the advertisement.'),
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
        String packageId = doc['package_id'];

        final packageDoc = await FirebaseFirestore.instance
            .collection('Travel_Packages')
            .doc(packageId)
            .get();

        if (!packageDoc.exists) {
          print("Package $packageId not found.");
          continue;
        }

        int quantityAvailable = packageDoc['quantity_available'];
        bool isAvailable = packageDoc['is_available'];

        if (endDate.isBefore(currentDate)) {
          await FirebaseFirestore.instance
              .collection('Advertisement')
              .doc(doc.id)
              .update({
            'status': 'ended',
          });
        } else if ((quantityAvailable == 0 || !isAvailable) &&
            doc['status'] != 'paused') {
          await FirebaseFirestore.instance
              .collection('Advertisement')
              .doc(doc.id)
              .update({'status': 'paused'});
        }
      }
    } catch (e) {
      print("Error updating ad status: $e");
    }
  }

  Future<bool> checkAdEligibility(String packageId) async {
    try {
      final packageSnapshot = await FirebaseFirestore.instance
          .collection('Travel_Packages')
          .where('id', isEqualTo: packageId)
          .get();

      for (var packageDoc in packageSnapshot.docs) {
        int quantityAvailable = packageDoc['quantity_available'];
        bool isAvailable = packageDoc['is_available'];
        Timestamp endDateTimestamp = packageDoc['end_date'];

        DateTime endDate = endDateTimestamp.toDate();
        DateTime currentDate = DateTime.now();

        if (quantityAvailable > 0 &&
            isAvailable &&
            endDate.isAfter(currentDate)) {
          return true;
        }
      }

      return false;
    } catch (e) {
      print("Error check ad eligibility: $e");
      return false;
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
          'renewal_type': doc['renewal_type'],
        });
      }

      return adDetails;
    } catch (e) {
      print("Error fetching ad details: $e");
      return [];
    }
  }

  // Ad Report
  Future<List<AdReport>> getAdReportDetails(String adId) async {
    try {
      final reportSnapshot = await FirebaseFirestore.instance
          .collection('AdReport')
          .where('ad_id', isEqualTo: adId)
          .get();

      List<AdReport> adReports = reportSnapshot.docs.map((doc) {
        return AdReport(
          adId: doc['ad_id'],
          reportDate: doc['report_date'].toDate(),
          clickCount: doc['click_count'],
          engagementRate: doc['engagement_rate'],
          successRate: doc['success_rate'],
          reach: doc['reach'],
          cpc: doc['cpc'],
          cpm: doc['cpm'],
          flatRate: doc['flat_rate'],
          revenue: doc['revenue'],
          roas: doc['roas'],
        );
      }).toList();

      return adReports;
    } catch (e) {
      print("Error fetching ad report details: $e");
      return [];
    }
  }

  Future<void> updateAdReport(
      String adId, int clickCount, int impressions) async {
    try {
      DateTime today = DateTime.now();
      DateTime startOfDay = DateTime(today.year, today.month, today.day);
      DateTime endOfDay = startOfDay.add(Duration(days: 1));

      var reportSnapshot = await FirebaseFirestore.instance
          .collection('AdReport')
          .where('ad_id', isEqualTo: adId)
          .where('report_date', isGreaterThanOrEqualTo: startOfDay)
          .where('report_date', isLessThan: endOfDay)
          .get();

      if (reportSnapshot.docs.isNotEmpty) {
        var existingReport = reportSnapshot.docs.first;

        int existingClickCount = existingReport['click_count'];
        double existingEngagementRate = existingReport['engagement_rate'];
        double existingRevenue = existingReport['revenue'];
        int existingReach = existingReport['reach'];
        double existingCpc = existingReport['cpc'];

        int updatedClickCount = existingClickCount + clickCount;
        double updatedEngagementRate =
            calculateEngagementRate(updatedClickCount, existingReach);
        double updatedRevenue =
            calculateRevenue(updatedClickCount, existingCpc);

        await FirebaseFirestore.instance
            .collection('AdReport')
            .doc(existingReport.id)
            .update({
          'click_count': updatedClickCount,
          'engagement_rate': updatedEngagementRate,
          'revenue': updatedRevenue,
        });
      } else {
        AdReport newReport = AdReport(
          adId: adId,
          reportDate: DateTime.now(),
          clickCount: 0,
          engagementRate: 0.0,
          successRate: 0.0,
          reach: 0,
          cpc: 0.0,
          cpm: 0.0,
          flatRate: 0.0,
          revenue: 0.0,
          roas: 0.0,
        );

        await FirebaseFirestore.instance
            .collection('AdReport')
            .add(newReport.toMap());
      }
    } catch (e) {
      print("Error updating ad report: $e");
    }
  }

  double calculateEngagementRate(int clickCount, int reach) {
    if (reach == 0) return 0.0;
    return (clickCount / reach) * 100;
  }

  double calculateRevenue(int clickCount, double cpc) {
    return clickCount * cpc;
  }
}
