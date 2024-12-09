// import 'package:flutter/material.dart';
// import 'package:tripify/view_models/ad_provider.dart';
// import 'package:tripify/models/ad_report_model.dart';

// class ViewAdsPerformancePage extends StatefulWidget {
//   final String adId; // The ID of the ad to fetch the report for

//   const ViewAdsPerformancePage({Key? key, required this.adId}) : super(key: key);

//   @override
//   _ViewAdsPerformancePageState createState() => _ViewAdsPerformancePageState();
// }

// class _ViewAdsPerformancePageState extends State<ViewAdsPerformancePage> {
//   late AdProvider adProvider;
//   List<AdReport> adReports = [];

//   @override
//   void initState() {
//     super.initState();
//     adProvider = AdProvider();
//     _fetchAdReportDetails();
//   }

//   // Fetch ad report details when the page loads
//   Future<void> _fetchAdReportDetails() async {
//     List<AdReport> reports = await adProvider.getAdReportDetails(widget.adId);
//     setState(() {
//       adReports = reports;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Ad Performance'),
//       ),
//       body: adReports.isEmpty
//           ? Center(child: CircularProgressIndicator())
//           : ListView.builder(
//               itemCount: adReports.length,
//               itemBuilder: (context, index) {
//                 final report = adReports[index];
//                 return Card(
//                   margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
//                   child: ListTile(
//                     title: Text('Report Date: ${report.reportDate.toLocal()}'),
//                     subtitle: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text('Click Count: ${report.clickCount}'),
//                         Text('Engagement Rate: ${report.engagementRate}%'),
//                         Text('Success Rate: ${report.successRate}%'),
//                         Text('Reach: ${report.reach}'),
//                         Text('CPC: \$${report.cpc}'),
//                         Text('CPM: \$${report.cpm}'),
//                         Text('Flat Rate: \$${report.flatRate}'),
//                         Text('Revenue: \$${report.revenue}'),
//                         Text('ROAS: ${report.roas}'),
//                       ],
//                     ),
//                   ),
//                 );
//               },
//             ),
//     );
//   }
// }
