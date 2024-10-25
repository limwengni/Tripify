import 'package:flutter/material.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';

class AccommodationRequirementPage extends StatefulWidget {
  const AccommodationRequirementPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementPageState();
  }
}

class _AccommodationRequirementPageState
    extends State<AccommodationRequirementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accommodation Requirement"),
      ),
      body: const Center(
        child: AccommodationRequirementCard(),
      ),
    );
  }
}
