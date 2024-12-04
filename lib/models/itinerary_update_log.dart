class ItineraryUpdateLog {
  final String itineraryId;
  final String userId;
  final DateTime updateTime;
  final String action; // The action that was taken (e.g., "added a location", "updated date")

  ItineraryUpdateLog({
    required this.itineraryId,
    required this.userId,
    required this.updateTime,
    required this.action,
  });
}
