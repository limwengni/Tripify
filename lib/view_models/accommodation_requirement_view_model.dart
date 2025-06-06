// import 'package:flutter/material.dart';
// import 'package:tripify/data/dummy_data.dart';
// import 'package:tripify/models/accommodation_requirement_model.dart';

// class AccommodationViewModel extends ChangeNotifier {
//   List<AccommodationRequirementModel> _accommodations = [];

//   List<AccommodationRequirementModel> get accommodations => _accommodations;

//   void fetchAccommodations() {
//     _accommodations = [
//       AccommodationRequirementModel(
//         id: '1',
//         title: 'Cozy Hotel Room',
//         location: 'New York',
//         checkinDate: DateTime.now(),
//         checkoutDate: DateTime.now().add(Duration(days: 2)),
//         guestNum: 2,
//         bedNum: 1,
//         budget: 150.0,
//         additionalRequirement: 'Wi-Fi included',
//         houseType: HouseType.banglow, 
//         userDocId: '',
//       ),
//       AccommodationRequirementModel(
//         id: '2',
//         title: 'Luxury Apartment',
//         location: 'Los Angeles',
//         checkinDate: DateTime.now().add(Duration(days: 1)),
//         checkoutDate: DateTime.now().add(Duration(days: 3)),
//         guestNum: 4,
//         bedNum: 2,
//         budget: 300.0,
//         additionalRequirement: 'Ocean view',
//         houseType: HouseType.banglow, 
//         userDocId: '',
//       ),
//     ];

//     notifyListeners(); // Notify listeners to update the UI
//   }
// }
