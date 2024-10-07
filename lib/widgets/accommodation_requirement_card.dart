import 'package:flutter/material.dart';

class AccommodationRequirementCard extends StatefulWidget {
  const AccommodationRequirementCard({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementCardState();
  }
}

class _AccommodationRequirementCardState extends State<AccommodationRequirementCard> {
  @override
  Widget build(BuildContext context) {
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          children: [
            Text("Accommodation Requirement Title"),
            Text("requirement details"), 
          ],
        ),
      ),
    );
  }
}
