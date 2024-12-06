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
  final DateTime createdAt;

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
    required this.createdAt,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'location': location,
      'checkin_date':  Timestamp.fromDate(checkinDate),
      'checkout_date':  Timestamp.fromDate(checkoutDate),
      'guest_num': guestNum,
      'bed_num': bedNum,
      'budget': budget,
      'additional_requirement': additionalRequirement,
      'house_type': houseType.toString().split('.').last,
      'user_doc_id': userDocId,
      'created_at': createdAt,
    };
  }
factory AccommodationRequirementModel.fromMap(Map<String, dynamic> data) {
  return AccommodationRequirementModel(
    id: data['id'] as String,
    title: data['title'] as String,
    location: data['location'] as String,
    checkinDate: (data['checkin_date'] is Timestamp)
        ? (data['checkin_date'] as Timestamp).toDate()
        : DateTime.parse(data['checkin_date']),
    checkoutDate: (data['checkout_date'] is Timestamp)
        ? (data['checkout_date'] as Timestamp).toDate()
        : DateTime.parse(data['checkout_date']),    createdAt: (data['created_at'] is Timestamp)
        ? (data['created_at'] as Timestamp).toDate()
        : DateTime.parse(data['created_at']),
    guestNum: data['guest_num'] as int,
    bedNum: data['bed_num'] as int,
    budget: data['budget'] as double,
    additionalRequirement: data['additional_requirement'] as String? ?? '',
    houseType: HouseType.values.firstWhere(
      (e) => e.toString().split('.').last == data['house_type'],
      orElse: () => HouseType.condo,
    ),
    userDocId: data['user_doc_id'] as String,
  );
}

}
