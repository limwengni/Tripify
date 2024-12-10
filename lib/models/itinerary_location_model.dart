class ItineraryLocation {
  final double latitude; // Latitude of the location
  final double longitude; // Longitude of the location
  final String name;

  ItineraryLocation({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  // Convert ItineraryLocation to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': name,
    };
  }

  // Factory method to create ItineraryLocation from Firestore data
  factory ItineraryLocation.fromMap(Map<String, dynamic> data) {
    return ItineraryLocation(
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      name: data['name'] ?? '',
    );
  }
}
