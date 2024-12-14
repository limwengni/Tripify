import 'package:cloud_firestore/cloud_firestore.dart';

class ItineraryLocation {
  final String id;
  final String name;
  GeoPoint location;

  ItineraryLocation({
    required this.id,
    required this.name,
    required this.location,
  });

  // Convert ItineraryLocation to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'location': location,
    };
  }

  // Factory method to create ItineraryLocation from Firestore data
  factory ItineraryLocation.fromMap(Map<String, dynamic> data, String id) {
    GeoPoint location = data['location'] ?? GeoPoint(0.0, 0.0);

    return ItineraryLocation(
      id: id,
      name: data['name'] ?? '',
      location: location,
    );
  }

  @override
  String toString() {
    return 'ItineraryLocation{id: $id, name: $name, latitude: ${location.latitude}, longitude: ${location.longitude}}';
  }
}
