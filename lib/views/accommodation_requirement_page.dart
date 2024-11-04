import 'package:flutter/material.dart';
import 'package:tripify/widgets/accommodation_requirement_card_list.dart';
import 'package:tripify/widgets/tripify_drawer.dart';

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
    return  const Center(
        child: Column(
          children: [
            Expanded(
              child: AccommodationRequirementCardList(),
            ),
          ],
        ),
    );
  }
}
