// import 'package:intl/intl.dart';
// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:tripify/views/ad_wallet_page.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:tripify/models/ad_report_model.dart';

// // class ViewAdsPerformancePage extends StatefulWidget {
// //   final String adId; // The ID of the ad to fetch the report for

//   const ViewAdsPerformancePage({Key? key, required this.adId})
//       : super(key: key);

// //   @override
// //   _ViewAdsPerformancePageState createState() => _ViewAdsPerformancePageState();
// // }

class OverallPerformance {
  int totalClicks;
  int totalImpressions;
  double totalRevenue;
  double engagementRate;
  double successRate;
  int totalReach;
  double totalFlatRate;
  double overallCPC;
  double overallCPM;
  double overallROAS;

  OverallPerformance({
    required this.totalClicks,
    required this.totalImpressions,
    required this.totalRevenue,
    required this.engagementRate,
    required this.successRate,
    required this.totalReach,
    required this.totalFlatRate,
    required this.overallCPC,
    required this.overallCPM,
    required this.overallROAS,
  });
}

class _ViewAdsPerformancePageState extends State<ViewAdsPerformancePage> {
  List<AdReport> adReports = [];
  String adType = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchAdReports();
//   }

  Future<void> fetchAdReports() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

//     try {
//       // Step 1: Fetch travel package purchases
//       final travelPackagesSnapshot = await FirebaseFirestore.instance
//           .collectionGroup('Travel_Packages_Purchased')
//           .where('ad_id', isEqualTo: widget.adId) // Filter by the specific adId
//           .get();

//       if (travelPackagesSnapshot.docs.isEmpty) {
//         debugPrint('No travel packages found for adId: ${widget.adId}');
//       } else {
//         for (var doc in travelPackagesSnapshot.docs) {
//           final data = doc.data() as Map<String, dynamic>; // Get data as a map
//           debugPrint('Document ID: ${doc.id}');
//           debugPrint(
//               'Travel Package Data: $data'); // Data of the travel package
//           final adId = data['ad_id'];
//           final price = data['price'];
//           final quantity = data['quantity'];
//         }
//       }

//       final reports = <AdReport>[];

//       for (var doc in travelPackagesSnapshot.docs) {
//         final purchaseData = doc.data();
//         final adId = purchaseData['ad_id'] as String?;

//         if (adId != null && adId.isNotEmpty) {
//           // Step 2: Fetch Ad details using ad_id
//           final adSnapshot = await FirebaseFirestore.instance
//               .collection('Advertisement')
//               .doc(adId)
//               .get();

          if (adSnapshot.exists) {
            final adData = adSnapshot.data()!;
            final price = purchaseData['price'] as num? ?? 0;
            final quantity = purchaseData['quantity'] as num? ?? 0;
            adType = adData['ad_type'];
            final cpcRate = adData['cpc_rate'] as num? ?? 0;
            final cpmRate = adData['cpm_rate'] as num? ?? 0;
            final flatRate = adData['flat_rate'] as num? ?? 0;

//             final today = DateTime.now();
//             final startOfDay = DateTime(today.year, today.month, today.day);
//             final endOfDay =
//                 DateTime(today.year, today.month, today.day, 23, 59, 59);

//             final adInteractionsSnapshot = await FirebaseFirestore.instance
//                 .collection('AdInteraction')
//                 .where('ad_id', isEqualTo: adId)
//                 .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
//                 .where('timestamp', isLessThanOrEqualTo: endOfDay)
//                 .get();

//             final totalImpressions = adInteractionsSnapshot.docs.length;
//             final uniqueUsers = adInteractionsSnapshot.docs
//                 .map((doc) => doc['user_id'])
//                 .toSet()
//                 .length;

            final clickCount = adInteractionsSnapshot.docs.length;

            final revenue = (clickCount / 1000) * cpmRate;

//             final engagementRate = totalImpressions > 0
//                 ? (clickCount / totalImpressions) * 100
//                 : 0;

//             final successRate =
//                 totalImpressions > 0 ? (quantity / totalImpressions) * 100 : 0;

//             final frequency =
//                 uniqueUsers > 0 ? totalImpressions / uniqueUsers : 0;

            final reach = (frequency > 0) ? totalImpressions / frequency : 0;

            final cpc =
                (cpcRate > 0 && clickCount > 0) ? revenue / clickCount : 0;
            final cpm = (cpmRate > 0 && totalImpressions > 0)
                ? (revenue / totalImpressions) * 1000
                : 0;

            final roas = flatRate > 0 ? revenue / flatRate : 0;

//             // Step 3: Check if there's already an existing report for the ad on the same day
//             final adReportSnapshot = await FirebaseFirestore.instance
//                 .collection('AdReport')
//                 .where('ad_id', isEqualTo: adId)
//                 .where('report_date', isGreaterThanOrEqualTo: startOfDay)
//                 .where('report_date', isLessThanOrEqualTo: endOfDay)
//                 .get();

//             AdReport adReport;

//             if (adReportSnapshot.docs.isNotEmpty) {
//               // Update the existing report
//               final existingData = adReportSnapshot.docs.first.data();
//               adReport = AdReport.fromMap(existingData);

//               adReport.clickCount = clickCount;
//               adReport.revenue = revenue.toDouble();
//               adReport.engagementRate = engagementRate.toDouble();
//               adReport.successRate = successRate.toDouble();
//               adReport.reach = reach.toInt();
//               adReport.cpc = cpc.toDouble();
//               adReport.cpm = cpm.toDouble();
//               adReport.roas = roas.toDouble();

//               await FirebaseFirestore.instance
//                   .collection('AdReport')
//                   .doc(adReportSnapshot.docs.first.id)
//                   .set(adReport.toMap(), SetOptions(merge: true));
//             } else {
//               // Create a new report
//               adReport = AdReport(
//                 adId: adId,
//                 reportDate: DateTime.now(),
//                 clickCount: clickCount,
//                 engagementRate: engagementRate.toDouble(),
//                 successRate: successRate.toDouble(),
//                 reach: reach.toInt(),
//                 cpc: cpc.toDouble(),
//                 cpm: cpm.toDouble(),
//                 flatRate: flatRate.toDouble(),
//                 revenue: revenue.toDouble(),
//                 roas: roas.toDouble(),
//               );

//               await FirebaseFirestore.instance
//                   .collection('AdReport')
//                   .add(adReport.toMap());
//             }

            final allReportsSnapshot = await FirebaseFirestore.instance
                .collection('AdReport')
                .where('ad_id', isEqualTo: adId)
                .get();

            final allReports = allReportsSnapshot.docs.map((doc) {
              final data = doc.data();
              return AdReport.fromMap(data);
            }).toList();

            reports.addAll(allReports);
          }
        }
      }

//       // Update state with reports
//       setState(() {
//         adReports = reports;
//       });
//     } catch (error) {
//       debugPrint('Error fetching ad reports: $error');
//     }
//   }

  @override
  Widget build(BuildContext context) {
    // Format the report date
    final dateFormat = DateFormat('dd MMM yyyy');
    int reportCount = adReports.length;

//     // Calculate overall performance (for example, summing up all reports)
//     final overallPerformance = _calculateOverallPerformance();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Performance'),
      ),
      body: adReports.isEmpty
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Overall Performance Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Card(
                      elevation: 5,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Overall Performance',
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 10),
                            // Ad Type Box
                            Card(
                              elevation: 3,
                              child: Container(
                                width: double.infinity, // Expands to 100% width
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Ad Type: ${adType ?? 'N/A'}',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              children: [
                                // First Row for Total Clicks, Total Cost, and ROAS
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Total Clicks Box
                                    _buildPerformanceBox(
                                      label: 'Total Clicks',
                                      value: overallPerformance.totalClicks
                                          .toString(),
                                    ),
                                    // Total Cost Box
                                    _buildPerformanceBox(
                                      label: 'Total Cost',
                                      value:
                                          'RM ${overallPerformance.totalFlatRate.toStringAsFixed(2)}',
                                    ),
                                    // ROAS Box
                                    _buildPerformanceBox(
                                      label: 'ROAS',
                                      value: overallPerformance.overallROAS
                                          .toStringAsFixed(2),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),

                                // Second Row for Total Revenue and Reach
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // Total Revenue Box
                                    _buildPerformanceBox(
                                      label: 'Total Revenue',
                                      value:
                                          'RM ${overallPerformance.totalRevenue.toStringAsFixed(2)}',
                                    ),
                                    // Reach Box
                                    _buildPerformanceBox(
                                      label: 'Reach',
                                      value: overallPerformance.totalReach
                                          .toString(),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // All Reports Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "All Reports ($reportCount)",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 10),
                        ...adReports.map((report) {
                          return _buildReportCard(report, dateFormat);
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

// Helper method for creating performance boxes
  Widget _buildPerformanceBox({required String label, required String value}) {
    return Flexible(
      child: Card(
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 5),
              Text(
                value,
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(AdReport report, DateFormat dateFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Ad ID: ${report.adId}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Report Date: ${dateFormat.format(report.reportDate)}'),
            Text('Click Count: ${report.clickCount}'),
            Text('Engagement Rate: ${report.engagementRate}%'),
            Text('Success Rate: ${report.successRate}%'),
            Text('Reach: ${report.reach}'),
            Text('CPC: \RM${report.cpc}'),
            Text('CPM: \RM${report.cpm}'),
            Text('Flat Rate: \RM${report.flatRate}'),
            Text('Revenue: \RM${report.revenue}'),
            Text('ROAS: ${report.roas}'),
          ],
        ),
      ),
    );
  }

  OverallPerformance _calculateOverallPerformance() {
    // Initialize variables for overall performance
    int totalClicks = 0;
    int totalImpressions = 0;
    int totalReach = 0;
    double totalFlatRate = 0;
    double totalRevenue = 0;
    double totalEngagementRate = 0;
    double totalSuccessRate = 0;

    // Sum up the data from all reports
    for (var report in adReports) {
      totalClicks += report.clickCount;
      totalRevenue += report.revenue;
      totalReach += report.reach;
      totalFlatRate = report.flatRate;
      totalEngagementRate +=
          report.engagementRate; // If averaging, divide by count later
      totalSuccessRate +=
          report.successRate; // If averaging, divide by count later
    }

    // Calculate averages (if needed)
    double averageEngagementRate =
        totalClicks > 0 ? totalEngagementRate / adReports.length : 0;
    double averageSuccessRate =
        totalClicks > 0 ? totalSuccessRate / adReports.length : 0;
    double overallCPC = totalClicks > 0 ? totalFlatRate / totalClicks : 0;
    double overallCPM =
        totalReach > 0 ? totalFlatRate / (totalReach / 1000) : 0;
    double overallROAS = totalFlatRate > 0 ? totalRevenue / totalFlatRate : 0;

    return OverallPerformance(
      totalClicks: totalClicks,
      totalImpressions: totalImpressions,
      totalRevenue: totalRevenue,
      engagementRate: averageEngagementRate,
      successRate: averageSuccessRate,
      totalReach: totalReach,
      totalFlatRate: totalFlatRate,
      overallCPC: overallCPC,
      overallCPM: overallCPM,
      overallROAS: overallROAS,
    );
  }
}
