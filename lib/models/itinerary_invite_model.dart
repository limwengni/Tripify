enum InviteStatus {
  pending,
  accepted,
  rejected,
  canceled, // Itinerary organizer cancel the inivitation
}

class ItineraryInvite {
  final String userId;
  final String role;
  final DateTime inviteDate;
  InviteStatus status;

  ItineraryInvite({
    required this.userId,
    required this.role,
    required this.inviteDate,
    this.status = InviteStatus.pending,
  });
}
