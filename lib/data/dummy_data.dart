//dummy_data.dart
import 'package:tripify/models/accommodation_requirement_model.dart';

AccommodationRequirement testAccommodation = AccommodationRequirement(
  id: '1',
  title: '5 Days New York Hotel',
  location: 'New York City',
  checkinDate: DateTime(2024, 10, 15),
  checkoutDate: DateTime(2024, 10, 20),
  guestNum: 2,
  bedNum: 1,
  budget: 150.0,
  additionalRequirement: 'Near subway station',
  houseType: HouseType.banglow, userDocId: '',
);

// Ensure the list contains your test data
List<AccommodationRequirement> accommodationsList = [
  AccommodationRequirement(
    id: '1',
    title: '5 Days New York Hotel',
    location: 'New York City',
    checkinDate: DateTime(2024, 10, 15),
    checkoutDate: DateTime(2024, 10, 20),
    guestNum: 2,
    bedNum: 1,
    budget: 150.0,
    additionalRequirement: 'Near subway station',
    houseType: HouseType.banglow, userDocId: '',
  ),
  AccommodationRequirement(
    id: '2',
    title: '5 Days Los Angel Hotel',
    location: 'Los Angeles',
    checkinDate: DateTime(2024, 11, 5),
    checkoutDate: DateTime(2024, 11, 10),
    guestNum: 4,
    bedNum: 2,
    budget: 300.0,
    additionalRequirement: '',
    houseType: HouseType.banglow, userDocId: '',
  ),
];
