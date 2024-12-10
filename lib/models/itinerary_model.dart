import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/itinerary_member_model.dart';
import 'package:tripify/models/itinerary_location_model.dart';
import 'package:tripify/models/itinerary_invite_model.dart';

class DayItinerary {
  final int dayNumber;
  final List<ItineraryLocation> locations;

  DayItinerary({
    required this.dayNumber,
    required this.locations,
  });

// Convert DayItinerary to Map for Firestore (No need to store ItineraryLocation separately)
  Map<String, dynamic> toMap() {
    return {
      'day_number': dayNumber,
      'locations': locations
          .map((loc) => loc.toMap())
          .toList(),
    };
  }

  // Factory method to create DayItinerary from Firestore data
  factory DayItinerary.fromMap(Map<String, dynamic> data) {
    return DayItinerary(
      dayNumber: data['day_number'] ?? 0,
      locations: (data['locations'] as List<dynamic>)
          .map((loc) => ItineraryLocation.fromMap(loc as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Itinerary {
  final String id;
  final String name;
  final DateTime startDate;
  final int numberOfDays;
  final List<ItineraryInvite>? invites;
  final List<ItineraryMember> members;
  final List<DayItinerary>
      dailyItineraries; // List of locations (latitude, longitude)
  final DateTime createdAt;
  DateTime? updatedAt;

  // Dynamically calculate endDate
  DateTime get endDate => startDate.add(Duration(days: numberOfDays - 1));

  Itinerary({
    required this.id,
    required this.name,
    required this.startDate,
    required this.numberOfDays,
    this.invites,
    required this.members,
    required this.dailyItineraries,
    required this.createdAt,
    this.updatedAt,
  });

  // Method to convert Itinerary to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'start_date': Timestamp.fromDate(startDate),
      'number_of_days': numberOfDays,
      'invites': invites?.map((invite) => invite.toMap()).toList(),
      'members': members.map((member) => member.toMap()).toList(),
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
      'daily_itineraries':
          dailyItineraries.map((dayItinerary) => dayItinerary.toMap()).toList(),
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
      invites: data['invites'] != null
          ? List<ItineraryInvite>.from((data['invites'] ?? [])
              .map((inviteData) => ItineraryInvite.fromMap(inviteData)))
          : null,
      members: List<ItineraryMember>.from(
        (data['members'] ?? [])
            .map((memberData) => ItineraryMember.fromMap(memberData)),
      ),
      dailyItineraries: List<DayItinerary>.from(
        (data['daily_itineraries'] ?? [])
            .map((dayData) => DayItinerary.fromMap(dayData)),
      ),
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
