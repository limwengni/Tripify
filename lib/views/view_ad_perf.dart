import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/views/ad_wallet_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/models/ad_report_model.dart';

class ViewAdsPerformancePage extends StatefulWidget {
  final String adId;
  final bool paused;
  const ViewAdsPerformancePage(
      {Key? key, required this.adId, required this.paused})
      : super(key: key);

  @override
  _ViewAdsPerformancePageState createState() => _ViewAdsPerformancePageState();
}

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
  DateTime? startDate;
  DateTime? endDate;
  int reportCount = 0;

  @override
  void initState() {
    super.initState();
    if (widget.paused == false) {
      fetchAdReports();
    } else {
      fetchHistoricalAdReports();
    }
  }

  final dateFormat = DateFormat('dd MMM yyyy');
  Future<void> _pickDateRange() async {
    final DateTime? pickedStartDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (pickedStartDate != null) {
      final DateTime? pickedEndDate = await showDatePicker(
        context: context,
        initialDate: pickedStartDate,
        firstDate: pickedStartDate,
        lastDate: DateTime.now(),
      );

      if (pickedEndDate != null) {
        setState(() {
          startDate = pickedStartDate;
          endDate = pickedEndDate;
          reportCount = _getFilteredReports().length;
        });
      }
    }
  }

  List<AdReport> _getFilteredReports() {
    if (startDate != null && endDate != null) {
      return adReports.where((report) {
        DateTime reportDate = DateTime(report.reportDate.year,
            report.reportDate.month, report.reportDate.day);
        DateTime start =
            DateTime(startDate!.year, startDate!.month, startDate!.day);
        DateTime end = DateTime(endDate!.year, endDate!.month, endDate!.day);

        return (reportDate.isAfter(start) ||
                reportDate.isAtSameMomentAs(start)) &&
            (reportDate.isBefore(end) || reportDate.isAtSameMomentAs(end));
      }).toList();
    }
    return adReports;
  }

  Future<int> getQuantityByDate(
      String adId, DateTime startOfDay, DateTime endOfDay) async {
    // Step 1: Fetch travel package data by adId
    final travelPackageSnapshot = await FirebaseFirestore.instance
        .collectionGroup(
            'Travel_Packages_Purchased') // This searches all 'Travel_Packages_Purchased' subcollections under any user
        .where('ad_id', isEqualTo: adId)
        .get();

    debugPrint(
        'Found ${travelPackageSnapshot.docs.length} packages for adId: $adId');

    if (travelPackageSnapshot.docs.isEmpty) {
      debugPrint('No travel packages found for adId: $adId');
      return 0;
    }

    // Step 2: Extract package IDs from travel packages
    List<String> packageIds = travelPackageSnapshot.docs
        .map((doc) => doc['travel_package_id'] as String)
        .toList();

    print("package id: $packageIds");

    // Step 3: Fetch receipts related to these packages
    final userReceiptsSnapshot = await FirebaseFirestore.instance
        .collectionGroup('Receipts')
        .where('travel_package_id', isEqualTo: packageIds.first)
        .where('created_at', isGreaterThanOrEqualTo: startOfDay)
        .where('created_at', isLessThanOrEqualTo: endOfDay)
        .get();

    if (userReceiptsSnapshot.docs.isEmpty) {
      debugPrint('No receipts found for these packages');
      return 0;
    }

    // Step 4: Process the receipts and count sales by date
    int totalQuantity = 0;

    for (var doc in userReceiptsSnapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;

      // Get the relevant fields from the receipt
      final ticketIdList = List<String>.from(data['ticket_id_list'] ?? []);
      final createdAt = (data['created_at'] as Timestamp).toDate();

      debugPrint('Ticket ID List: $ticketIdList');
      debugPrint('Created At: $createdAt');

      if (createdAt.isAfter(startOfDay) && createdAt.isBefore(endOfDay)) {
        totalQuantity += ticketIdList.length;
      }
    }

    return totalQuantity;
  }

  // Function to check if the ad is renewed
  bool isAdRenewed(List<AdReport> allReports, DateTime startDate) {
    // Check if there are two reports on the same day
    final reportsGroupedByDate = <DateTime, List<AdReport>>{};

    // Group reports by date
    for (var report in allReports) {
      final reportDate = report.reportDate;
      final dateOnly =
          DateTime(reportDate.year, reportDate.month, reportDate.day);

      if (reportsGroupedByDate.containsKey(dateOnly)) {
        reportsGroupedByDate[dateOnly]!.add(report);
      } else {
        reportsGroupedByDate[dateOnly] = [report];
      }
    }

    // Check for reports on the same day
    for (var reportsOnSameDay in reportsGroupedByDate.values) {
      if (reportsOnSameDay.length > 1) {
        // More than 1 report on the same day, means renewed
        return true;
      }
    }

    // If no reports on the same day, check if any report is before the start date (old report)
    for (var report in allReports) {
      if (report.reportDate.isBefore(startDate)) {
        // This report is before the start date, so it's an old report
        return false;
      }
    }

    return true;
  }

  Future<void> fetchAdReports() async {
    final userId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Step 1: Fetch travel package purchases
      final travelPackagesSnapshot = await FirebaseFirestore.instance
          .collectionGroup('Travel_Packages_Purchased')
          .where('ad_id', isEqualTo: widget.adId) // Filter by the specific adId
          .get();

      if (travelPackagesSnapshot.docs.isEmpty) {
        debugPrint('No travel packages found for adId: ${widget.adId}');
      } else {
        for (var doc in travelPackagesSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>; // Get data as a map
          debugPrint('Document ID: ${doc.id}');
          debugPrint(
              'Travel Package Data: $data'); // Data of the travel package
          final adId = data['ad_id'];
          final price = data['price'];
        }
      }

      final reports = <AdReport>[];

      for (var doc in travelPackagesSnapshot.docs) {
        final purchaseData = doc.data();
        final adId = purchaseData['ad_id'] as String?;

        if (adId != null && adId.isNotEmpty) {
          // Step 2: Fetch Ad details using ad_id
          final adSnapshot = await FirebaseFirestore.instance
              .collection('Advertisement')
              .doc(adId)
              .get();

          if (adSnapshot.exists) {
            final today = DateTime.now();
            final startOfDay = DateTime(today.year, today.month, today.day);
            final endOfDay =
                DateTime(today.year, today.month, today.day, 23, 59, 59);

            final adData = adSnapshot.data()!;
            final price = purchaseData['price'] as num? ?? 0;
            final quantity =
                await getQuantityByDate(adId, startOfDay, endOfDay);
            print("qty: $quantity");
            adType = adData['ad_type'];
            final cpcRate = adData['cpc_rate'] as num? ?? 0;
            final cpmRate = adData['cpm_rate'] as num? ?? 0;
            final flatRate = adData['flat_rate'] as num? ?? 0;

            final startDate = adData['start_date'].toDate();

            final adInteractionsSnapshot = await FirebaseFirestore.instance
                .collection('AdInteraction')
                .where('ad_id', isEqualTo: adId)
                .where('timestamp', isGreaterThanOrEqualTo: startOfDay)
                .where('timestamp', isLessThanOrEqualTo: endOfDay)
                .get();

            final totalImpressions = adInteractionsSnapshot.docs.length;
            final uniqueUsers = adInteractionsSnapshot.docs
                .map((doc) => doc['user_id'])
                .toSet()
                .length;

            final clickCount = adInteractionsSnapshot.docs.length;

            final revenue = (clickCount / 1000) * cpmRate;

            final engagementRate = totalImpressions > 0
                ? (clickCount / totalImpressions) * 100
                : 0;

            final successRate =
                totalImpressions > 0 ? (quantity / totalImpressions) * 100 : 0;

            final frequency =
                uniqueUsers > 0 ? totalImpressions / uniqueUsers : 0;

            final reach = (frequency > 0) ? totalImpressions / frequency : 0;

            final cpc =
                (cpcRate > 0 && clickCount > 0) ? revenue / clickCount : 0;
            final cpm = (cpmRate > 0 && totalImpressions > 0)
                ? (revenue / totalImpressions) * 1000
                : 0;

            final roas = flatRate > 0 ? revenue / flatRate : 0;

            // Step 3: Check if there's already an existing report for the ad on the same day
            final adReportSnapshot = await FirebaseFirestore.instance
                .collection('AdReport')
                .where('ad_id', isEqualTo: adId)
                .where('report_date', isGreaterThanOrEqualTo: startOfDay)
                .where('report_date', isLessThanOrEqualTo: endOfDay)
                .get();

            AdReport adReport;

            if (adReportSnapshot.docs.isNotEmpty) {
              // Update the existing report
              final reports = adReportSnapshot.docs
                  .map((doc) => doc.data())
                  .toList()
                ..sort((a, b) => b['report_date'].compareTo(a['report_date']));

              final latestReport = reports.isNotEmpty ? reports.first : null;

              if (latestReport != null) {
                adReport = AdReport.fromMap(latestReport);

                adReport.clickCount = clickCount;
                adReport.revenue = revenue.toDouble();
                adReport.engagementRate = engagementRate.toDouble();
                adReport.successRate = successRate.toDouble();
                adReport.reach = reach.toInt();
                adReport.cpc = cpc.toDouble();
                adReport.cpm = cpm.toDouble();
                adReport.roas = roas.toDouble();

                await FirebaseFirestore.instance
                    .collection('AdReport')
                    .doc(adReportSnapshot.docs.first.id)
                    .set(adReport.toMap(), SetOptions(merge: true));
              }
            } else {
              // Create a new report
              adReport = AdReport(
                adId: adId,
                reportDate: DateTime.now(),
                clickCount: clickCount,
                engagementRate: engagementRate.toDouble(),
                successRate: successRate.toDouble(),
                reach: reach.toInt(),
                cpc: cpc.toDouble(),
                cpm: cpm.toDouble(),
                flatRate: flatRate.toDouble(),
                revenue: revenue.toDouble(),
                roas: roas.toDouble(),
              );

              await FirebaseFirestore.instance
                  .collection('AdReport')
                  .add(adReport.toMap());
            }

            final allReportsSnapshot = await FirebaseFirestore.instance
                .collection('AdReport')
                .where('ad_id', isEqualTo: adId)
                .get();

            final allReports = allReportsSnapshot.docs.map((doc) {
              final data = doc.data();
              return AdReport.fromMap(data);
            }).toList();

            final isRenewed = isAdRenewed(allReports, startDate);

            if (isRenewed) {
              final latestReport = allReports.where((report) {
                // Check if the report was created after the start date or any other relevant condition
                return isReportNew(report, startDate);
              }).toList()
                ..sort((a, b) => b.reportDate.compareTo(
                    a.reportDate)); // Sort in descending order by created_at

              if (latestReport.isNotEmpty) {
                reports.add(
                    latestReport.first); // Add the latest report to the list
              } else {
                debugPrint('No new reports found.');
              }
            } else {
              debugPrint('Ad is not renewed, handling as a new ad.');
              // You can choose to handle new ads (e.g., still showing reports for ongoing ads)
              reports.addAll(
                  allReports); // For new ongoing ads, add reports anyway
            }
          }
        }
      }

      // Update state with reports
      setState(() {
        adReports = reports;
      });
    } catch (error) {
      debugPrint('Error fetching ad reports: $error');
    }
  }

  bool isReportNew(AdReport report, DateTime startDate) {
    // Assuming the report has a created_at field (adjust as needed)
    return report.reportDate.isAfter(startDate); // New if it’s after startDate
  }

  Future<void> fetchHistoricalAdReports() async {
    try {
      // Fetch historical reports directly using ad_id
      final adReportSnapshot = await FirebaseFirestore.instance
          .collection('AdReport')
          .where('ad_id', isEqualTo: widget.adId)
          .get();

      if (adReportSnapshot.docs.isEmpty) {
        debugPrint('No historical reports found for adId: ${widget.adId}');
        setState(() {
          adReports = [];
        });
      } else {
        // Parse the reports into a list of AdReport objects
        final reports = adReportSnapshot.docs.map((doc) {
          final data = doc.data();
          return AdReport.fromMap(data);
        }).toList();

        // Update state with fetched reports
        setState(() {
          adReports = reports;
        });

        debugPrint(
            'Fetched ${reports.length} historical reports for adId: ${widget.adId}');
      }
    } catch (error) {
      debugPrint('Error fetching historical ad reports: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy');

    final overallPerformance = _calculateOverallPerformance();

    List<AdReport> filteredReports = _getFilteredReports();

    return Scaffold(
      appBar: AppBar(
        title: Text('Ad Performance'),
      ),
      body: adReports.isEmpty
          ? Center(child: Text('No reports for now. Thank you!'))
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
                            // Ad ID Box
                            Card(
                              elevation: 3,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Text(
                                      'ID: ${adReports.first.adId}',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            // Ad Type Box
                            Card(
                              elevation: 3,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                    color: Colors.blue[50],
                                    borderRadius: BorderRadius.circular(10)),
                                child: Row(
                                  children: [
                                    Text(
                                      'Ad Type: $adType',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView(
                              shrinkWrap: true,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'Total Clicks',
                                        value: overallPerformance.totalClicks
                                            .toString(),
                                        icon: Icons.ads_click,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'Total Cost',
                                        value:
                                            'RM ${overallPerformance.totalFlatRate.toStringAsFixed(2)}',
                                        icon: Icons.money,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'ROAS',
                                        value: overallPerformance.overallROAS
                                            .toStringAsFixed(2),
                                        icon: Icons.show_chart,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'Total Revenue',
                                        value:
                                            'RM ${overallPerformance.totalRevenue.toStringAsFixed(2)}',
                                        icon: Icons.attach_money,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'Reach',
                                        value: overallPerformance.totalReach
                                            .toString(),
                                        icon: Icons.people,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'Engagement Rate (%)',
                                        value: overallPerformance.engagementRate
                                            .toStringAsFixed(2),
                                        icon: Icons.remove_red_eye_sharp,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Expanded(
                                      child: _buildPerformanceBox(
                                        label: 'Success Rate (%)',
                                        value: overallPerformance.successRate
                                            .toStringAsFixed(2),
                                        icon: Icons.check_circle,
                                      ),
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

                  SizedBox(height: 10),

                  // Performance Graph Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Container(
                      height: 300,
                      child: _buildPerformanceGraph(),
                    ),
                  ),

                  // All Reports Section
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title for All Reports
                        Text(
                          "All Reports (${filteredReports.length})",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                            height:
                                10), // Space between title and the filter section

                        // Filter Section: Date Range Picker
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  ElevatedButton(
                                    onPressed: _pickDateRange,
                                    child: Text('Select Date Range'),
                                  ),
                                ],
                              ),

                              // If the date range is selected, show it
                              if (startDate != null && endDate != null)
                                Text(
                                  'From: ${dateFormat.format(startDate!)} To: ${dateFormat.format(endDate!)}',
                                  style: TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                            ],
                          ),
                        ),

                        SizedBox(
                            height:
                                10), // Adding space between filter and report cards

                        // Displaying the list of reports based on the filter
                        if (filteredReports.isEmpty)
                          Center(
                              child: Text(
                                  "No reports found for the selected date range.")),
                        ...filteredReports.map((report) {
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

  Widget _buildPerformanceBox({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          if (icon != null) Icon(icon, size: 18, color: Colors.blue),
          SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.blue),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(AdReport report, DateFormat dateFormat) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        title: Text('Report Date: ${dateFormat.format(report.reportDate)}',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
    int totalClicks = 0;
    int totalImpressions = 0;
    int totalReach = 0;
    double totalFlatRate = 0;
    double totalRevenue = 0;
    double totalEngagementRate = 0;
    double totalSuccessRate = 0;

    for (var report in adReports) {
      totalClicks += report.clickCount;
      totalRevenue += report.revenue;
      totalReach += report.reach;
      totalFlatRate = report.flatRate;
      totalEngagementRate += report.engagementRate;
      totalSuccessRate += report.successRate;
    }

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

  Widget _buildPerformanceGraph() {
    List<FlSpot> revenueData = [];
    List<FlSpot> clickData = [];
    List<FlSpot> reachData = [];

    for (int i = 0; i < adReports.length; i++) {
      var report = adReports[i];
      revenueData.add(FlSpot(i.toDouble(), report.revenue));
      clickData.add(FlSpot(i.toDouble(), report.clickCount.toDouble()));
      reachData.add(FlSpot(i.toDouble(), report.reach.toDouble()));
    }

    int numOfDays = _getNumOfDaysInMonth();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'Daily Performance Graph',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ),
        Expanded(
          child: LineChart(
            LineChartData(
              gridData: FlGridData(show: true),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    getTitlesWidget: (double value, TitleMeta meta) {
                      String text;
                      if (adType == '1 Month') {
                        text = 'Day ${value.toInt() + 1}';
                        if (value.toInt() >= numOfDays) {
                          text = '';
                        }
                      } else {
                        text = 'Day ${value.toInt() + 1}';
                      }

                      return SideTitleWidget(
                        axisSide: meta.axisSide,
                        space: 10,
                        child: Text(
                          text,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                      );
                    },
                    interval: 1,
                    showTitles: true,
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (double value, TitleMeta meta) {
                      String text = value.toInt().toString();
                      return Text(
                        text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.blue, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: revenueData,
                  isCurved: true,
                  color: Colors.green,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: clickData,
                  isCurved: true,
                  color: Colors.blue,
                  belowBarData: BarAreaData(show: false),
                ),
                LineChartBarData(
                  spots: reachData,
                  isCurved: true,
                  color: Colors.orange,
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legendItem(Colors.green, 'Revenue'),
              SizedBox(width: 10),
              _legendItem(Colors.blue, 'Clicks'),
              SizedBox(width: 10),
              _legendItem(Colors.orange, 'Reach'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 20,
          height: 20,
          color: color,
        ),
        SizedBox(width: 5),
        Text(
          label,
          style: TextStyle(fontSize: 14),
        ),
      ],
    );
  }

  int _getNumOfDaysInMonth() {
    DateTime now = DateTime.now();
    if ([4, 6, 9, 11].contains(now.month)) {
      return 30;
    }
    if (now.month == 2) {
      return (now.year % 4 == 0 && (now.year % 100 != 0 || now.year % 400 == 0))
          ? 29
          : 28;
    }
    return 31;
  }
}
