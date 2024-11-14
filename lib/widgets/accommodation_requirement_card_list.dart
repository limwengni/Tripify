import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';

class AccommodationRequirementCardList extends StatefulWidget {
  final List<AccommodationRequirementModel> accommodationsList;
  const AccommodationRequirementCardList({super.key, required this.accommodationsList});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementCardListState();
  }
}

class _AccommodationRequirementCardListState
    extends State<AccommodationRequirementCardList> {

  @override
  Widget build(BuildContext context) {
    return widget.accommodationsList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: widget.accommodationsList.length,
            itemBuilder: (context, index) => AccommodationRequirementCard(
                accommodationRequirement: widget.accommodationsList[index]),
          );
  }
}
