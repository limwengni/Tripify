import 'package:cloud_firestore/cloud_firestore.dart';

class AdReport {
  final String adId;
  final DateTime reportDate;
   int clickCount;
   double engagementRate;
   double successRate;
   int reach;
   double cpc;
   double cpm;
   double flatRate;
   double revenue;
   double roas;

  AdReport({
    required this.adId,
    required this.reportDate,
    required this.clickCount,
    required this.engagementRate,
    required this.successRate,
    required this.reach,
    required this.cpc,
    required this.cpm,
    required this.flatRate,
    required this.revenue,
    required this.roas,
  });

  // Convert to a map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'ad_id': adId,
      'report_date': reportDate,
      'click_count': clickCount,
      'engagement_rate': engagementRate,
      'success_rate': successRate,
      'reach': reach,
      'cpc': cpc,
      'cpm': cpm,
      'flat_rate': flatRate,
      'revenue': revenue,
      'roas': roas,
    };
  }

  factory AdReport.fromMap(Map<String, dynamic> map) {
    return AdReport(
      adId: map['ad_id'] ?? '',
      reportDate: (map['report_date'] as Timestamp).toDate(),
      clickCount: map['click_count']?.toInt() ?? 0,
      engagementRate: map['engagement_rate']?.toDouble() ?? 0.0,
      successRate: map['success_rate']?.toDouble() ?? 0.0,
      reach: map['reach']?.toInt() ?? 0,
      cpc: map['cpc']?.toDouble() ?? 0.0,
      cpm: map['cpm']?.toDouble() ?? 0.0,
      flatRate: map['flat_rate']?.toDouble() ?? 0.0,
      revenue: map['revenue']?.toDouble() ?? 0.0,
      roas: map['roas']?.toDouble() ?? 0.0,
    );
  }
}
