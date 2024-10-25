class AccommodationRequirement {
  final String id;
  final String location;
  final DateTime checkinDate;
  final DateTime checkoutDate;
  final int guestNum;
  final int bedNum;
  final double budget;
  final String additionalRequirement;

  AccommodationRequirement({
    required this.id,
    required this.location,
    required this.checkinDate,
    required this.checkoutDate,
    required this.guestNum,
    required this.bedNum,
    required this.budget,
    this.additionalRequirement = '',
  });
}
