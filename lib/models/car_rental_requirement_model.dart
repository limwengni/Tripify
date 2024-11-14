import 'package:cloud_firestore/cloud_firestore.dart';

enum CarType {
  sedan,
  suv,
  hatchback,
  coupe,
  convertible,
  minivan,
  sportsCar,
  electric,
  hybrid,
}

class CarRentalRequirementModel {
  final String id;
  final String title;
  final String pickupLocation;
  final String returnLocation;
  final DateTime pickupDate;
  final DateTime returnDate;
  final double budget;
  final String additionalRequirement;
  final CarType carType;
  final String userDocId;

  CarRentalRequirementModel({
    required this.id,
    required this.title,
    required this.pickupLocation,
    required this.returnLocation,
    required this.pickupDate,
    required this.returnDate,
    required this.budget,
    required this.additionalRequirement,
    required this.carType,
    required this.userDocId,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'pickupLocation': pickupLocation,
      'returnLocation': returnLocation,
      'pickupDate': Timestamp.fromDate(pickupDate),
      'returnDate': Timestamp.fromDate(returnDate),
      'budget': budget,
      'additionalRequirement': additionalRequirement,
      'carType': carType.toString().split('.').last,
      'userDocId': userDocId,
    };
  }

  factory CarRentalRequirementModel.fromMap(Map<String, dynamic> data) {
    return CarRentalRequirementModel(
      id: data['id'] as String,
      title: data['title'] as String,
      pickupLocation: data['pickupLocation'] as String,
      returnLocation: data['returnLocation'] as String,
      pickupDate: (data['pickupDate'] is Timestamp)
          ? (data['pickupDate'] as Timestamp).toDate()
          : DateTime.parse(data['pickupDate']),
      returnDate: (data['returnDate'] is Timestamp)
          ? (data['returnDate'] as Timestamp).toDate()
          : DateTime.parse(data['returnDate']),
      budget: data['budget'] as double,
      additionalRequirement: data['additionalRequirement'] as String? ?? '',
      carType: CarType.values.firstWhere(
        (e) => e.toString().split('.').last == data['carType'],
        orElse: () => CarType.sedan,
      ),
      userDocId: data['userDocId'] as String,
    );
  }
}
