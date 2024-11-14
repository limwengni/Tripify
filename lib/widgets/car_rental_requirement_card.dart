import 'package:flutter/material.dart';
import 'package:tripify/models/car_rental_requirement_model.dart';

class CarRentalRequirementCard extends StatefulWidget {
  final CarRentalRequirementModel carRentalRequirement;
  const CarRentalRequirementCard(
      {super.key, required this.carRentalRequirement});

  @override
  State<StatefulWidget> createState() {
    return _CarRentalRequirementCardState();
  }
}

class _CarRentalRequirementCardState extends State<CarRentalRequirementCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
        child: SizedBox(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.carRentalRequirement.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.keyboard_arrow_right_outlined,
                      size: 30,
                    )),
              ],
            ),
            Table(
  columnWidths: const {
    0: IntrinsicColumnWidth(),
    1: FlexColumnWidth(),
  },
  children: [
    TableRow(children: [
      const Text("Pickup Location:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.pickupLocation}"),
      ),
    ]),
    TableRow(children: [
      const Text("Return Location:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.returnLocation}"),
      ),
    ]),
    TableRow(children: [
      const Text("Pickup Date:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.pickupDate}"),
      ),
    ]),
    TableRow(children: [
      const Text("Return Date:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.returnDate}"),
      ),
    ]),
    TableRow(children: [
      const Text("Car Type:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.carType}"),
      ),
    ]),
    TableRow(children: [
      const Text("Budget:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.budget}"),
      ),
    ]),
    TableRow(children: [
      const Text("Additional Requirement:"),
      Padding(
        padding: const EdgeInsets.only(left: 10.0), // Add space here
        child: Text("${widget.carRentalRequirement.additionalRequirement}"),
      ),
    ]),
  ],
)

          ],
        ),
      ),
    ));
  }
}
