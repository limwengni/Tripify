import 'package:flutter/material.dart';
import 'package:tripify/widgets/accommodation_requirement_card_list.dart';
import 'package:tripify/widgets/tripify_drawer.dart';

class AccommodationRequirementView extends StatefulWidget {
  const AccommodationRequirementView({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementViewState();
  }
}

class _AccommodationRequirementViewState
    extends State<AccommodationRequirementView> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accommodation Requirement"),
      ),
      drawer: const TripifyDrawer(),
     
      body: const Center(
        child: Column(
          children: [
            Expanded(
              child: AccommodationRequirementCardList(),
            ),
          ],
        ),
      ),
    );
  }
}
