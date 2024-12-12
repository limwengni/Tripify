class ItineraryLocation {
  final String id;
  final double latitude; // Latitude of the location
  final double longitude; // Longitude of the location
  final String name;

  ItineraryLocation({
    required this.id,
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
  factory ItineraryLocation.fromMap(Map<String, dynamic> data, String id) {
    return ItineraryLocation(
      id: id,
      latitude: data['latitude'] ?? 0.0,
      longitude: data['longitude'] ?? 0.0,
      name: data['name'] ?? '',
    );
  }
}
