import 'package:flutter/material.dart';
import 'package:tripify/data/dummy_data.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';

class AccommodationRequirementCardList extends StatefulWidget {
  const AccommodationRequirementCardList({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementCardListState();
  }
}

class _AccommodationRequirementCardListState
    extends State<AccommodationRequirementCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: accommodationsList.length,
      itemBuilder: (context, index) => AccommodationRequirementCard(
          accommodationRequirement: accommodationsList[index]),
    );
  }
}
