import 'package:flutter/material.dart';
import 'package:tripify/models/car_rental_requirement_model.dart';
import 'package:tripify/widgets/car_rental_requirement_card.dart';

class CarRentalRequirementCardList extends StatefulWidget {
  final List<CarRentalRequirementModel> carRentalRequirmentsList;
  const CarRentalRequirementCardList({super.key, required this.carRentalRequirmentsList});

  @override
  State<StatefulWidget> createState() {
    return _CarRentalRequirementCardListState();
  }
}

class _CarRentalRequirementCardListState
    extends State<CarRentalRequirementCardList> {

  @override
  Widget build(BuildContext context) {
    return widget.carRentalRequirmentsList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: widget.carRentalRequirmentsList.length,
            itemBuilder: (context, index) => CarRentalRequirementCard(
               carRentalRequirement: widget.carRentalRequirmentsList[index]),
          );
  }
}
