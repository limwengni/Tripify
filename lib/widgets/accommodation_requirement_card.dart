import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';

class AccommodationRequirementCard extends StatefulWidget {
  final AccommodationRequirement accommodationRequirement;
  const AccommodationRequirementCard({super.key, required this.accommodationRequirement});

  @override
  State<StatefulWidget> createState() {
    return _AccommodationRequirementCardState();
  }
}

class _AccommodationRequirementCardState
    extends State<AccommodationRequirementCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black),
        ),
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
                      widget.accommodationRequirement.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.keyboard_arrow_right_outlined,
                          size: 30,
                        )),
                  ],
                ),
                Text("location: ${widget.accommodationRequirement.location}"),
                Text("location: ${widget.accommodationRequirement.checkinDate}"),
                Text("location: ${widget.accommodationRequirement.checkoutDate}"),
                Text("location: ${widget.accommodationRequirement.guestNum}"),
                Text("location: ${widget.accommodationRequirement.bedNum}"),
                Text("location: ${widget.accommodationRequirement.budget}"),
                Text("location: ${widget.accommodationRequirement.additionalRequirement}"),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
