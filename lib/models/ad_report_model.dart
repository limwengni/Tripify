class AdReport {
  final String adId;
  final DateTime reportDate;
  final int clickCount;
  final double engagementRate;
  final double successRate;
  final int reach;
  final double cpc;
  final double cpm;
  final double flatRate;
  final double revenue;
  final double roas;

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
}
