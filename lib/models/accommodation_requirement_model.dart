import 'package:cloud_firestore/cloud_firestore.dart';

enum HouseType {
  condo,
  semiD,
  banglow,
  landed,
  hotel,
}

class AccommodationRequirementModel {
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
  final String userDocId;

  AccommodationRequirementModel({
    required this.id,
    required this.title,
    required this.location,
    required this.checkinDate,
    required this.checkoutDate,
    required this.guestNum,
    required this.bedNum,
    required this.budget,
    required this.additionalRequirement,
    required this.houseType,
    required this.userDocId,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'checkinDate':  Timestamp.fromDate(checkinDate),
      'checkoutDate':  Timestamp.fromDate(checkoutDate),
      'guestNum': guestNum,
      'bedNum': bedNum,
      'budget': budget,
      'additionalRequirement': additionalRequirement,
      'houseType': houseType.toString().split('.').last,
      'userDocId': userDocId,
    };
  }
factory AccommodationRequirementModel.fromMap(Map<String, dynamic> data) {
  return AccommodationRequirementModel(
    id: data['id'] as String,
    title: data['title'] as String,
    location: data['location'] as String,
    checkinDate: (data['checkinDate'] is Timestamp)
        ? (data['checkinDate'] as Timestamp).toDate()
        : DateTime.parse(data['checkinDate']),
    checkoutDate: (data['checkoutDate'] is Timestamp)
        ? (data['checkoutDate'] as Timestamp).toDate()
        : DateTime.parse(data['checkoutDate']),
    guestNum: data['guestNum'] as int,
    bedNum: data['bedNum'] as int,
    budget: data['budget'] as double,
    additionalRequirement: data['additionalRequirement'] as String? ?? '',
    houseType: HouseType.values.firstWhere(
      (e) => e.toString().split('.').last == data['houseType'],
      orElse: () => HouseType.condo,
    ),
    userDocId: data['userDocId'] as String,
  );
}

}
