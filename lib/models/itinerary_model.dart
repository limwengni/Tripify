import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/itinerary_member_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/models/itinerary_invite_model.dart';

class DayItinerary {
  final String id;
  final String itineraryId;
  final int dayNumber;
  final List<String> locationIds;
  final DateTime createdAt;
  DateTime? updatedAt;

  DayItinerary({
    required this.id,
    required this.itineraryId,
    required this.dayNumber,
    required this.locationIds,
    required this.createdAt,
    this.updatedAt,
  });

// Convert DayItinerary to Map for Firestore (No need to store ItineraryLocation separately)
  Map<String, dynamic> toMap() {
    return {
      'itinerary_id': itineraryId,
      'day_number': dayNumber,
      'location_ids': locationIds,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  // Factory method to create DayItinerary from Firestore data
  factory DayItinerary.fromMap(Map<String, dynamic> data) {
    return DayItinerary(
      id: data['id'],
      itineraryId: data['itinerary_id'],
      dayNumber: data['day_number'] ?? 0,
      locationIds: List<String>.from(data['location_ids'] ?? []),
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : (data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null),
    );
  }
}

class Itinerary {
  final String id;
  String name;
  final DateTime startDate;
  final int numberOfDays;
  final List<String>?
      dailyItineraryIds; // List of references to DailyItinerary documents
  final DateTime createdAt;
  DateTime? updatedAt;
  bool isOwner;

  // Dynamically calculate endDate
  DateTime get endDate => startDate.add(Duration(days: numberOfDays - 1));

  Itinerary({
    required this.id,
    required this.name,
    required this.startDate,
    required this.numberOfDays,
    this.dailyItineraryIds,
    required this.createdAt,
    this.updatedAt,
    this.isOwner = false,
  });

  // Method to convert Itinerary to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_date': Timestamp.fromDate(startDate),
      'number_of_days': numberOfDays,
      'created_at': Timestamp.fromDate(createdAt),
    };
  }

  // Factory method to create Itinerary from Firestore data
  factory Itinerary.fromMap(Map<String, dynamic> data) {
    return Itinerary(
      id: data['id'],
      name: data['name'],
      startDate: (data['start_date'] is Timestamp)
          ? (data['start_date'] as Timestamp).toDate()
          : DateTime.parse(data['start_date']),
      numberOfDays: data['number_of_days'] ?? 0,
      dailyItineraryIds: List<String>.from(
          data['daily_itinerary_ids'] ?? []), // Reference to DailyItinerary
      createdAt: (data['created_at'] is Timestamp)
          ? (data['created_at'] as Timestamp).toDate()
          : DateTime.parse(data['created_at']),
      updatedAt: (data['updated_at'] is Timestamp)
          ? (data['updated_at'] as Timestamp).toDate()
          : (data['updated_at'] != null
              ? DateTime.parse(data['updated_at'])
              : null),
    );
  }
}
