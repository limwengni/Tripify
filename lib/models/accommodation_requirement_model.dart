import 'package:cloud_firestore/cloud_firestore.dart';

enum HouseType {
  condo,
  semiD,
  banglow,
  landed,
  hotel,
}

class AccommodationRequirement {
  final String id;
  final String title;
  final String location;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final int guestNum;
  final int bedNum;
  final double budget;
  final String additionalRequirement;
  final HouseType houseType;

  AccommodationRequirement({
    required this.id,
    required this.title,
    required this.location,
    required this.checkinDate,
    required this.checkoutDate,
    required this.guestNum,
    required this.bedNum,
    required this.budget,
    this.additionalRequirement = '',
    required this.houseType,
  });

  factory AccommodationRequirement.fromMap(Map<String, dynamic> data) {
    return AccommodationRequirement(
      id: data['id'] as String,
      title: data['title'] as String,
      location: data['location'] as String,
      checkinDate: (data['checkin_date'] is Timestamp)
          ? (data['checkin_date'] as Timestamp).toDate()
          : DateTime.parse(data['checkinDate']),
      checkoutDate: (data['checkout_date'] is Timestamp)
          ? (data['checkout_date'] as Timestamp).toDate()
          : DateTime.parse(data['checkoutDate']),
      guestNum: data['guestNum'] as int,
      bedNum: data['bedNum'] as int,
      budget: data['budget'] as double,
      additionalRequirement: data['additionalRequirement'] as String? ?? '',
      houseType: HouseType.values.firstWhere(
        (e) => e.toString().split('.').last == data['houseType'],
        orElse: () => HouseType.condo,
      ),
    );
  }
}
