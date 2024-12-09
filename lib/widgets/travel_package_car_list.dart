import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/new_travel_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';
import 'package:tripify/widgets/travel_package_card.dart';

class TravelPackageCardList extends StatefulWidget {
  final List<NewTravelPackageModel> travelPackagesList;
  final String currentUserId;
  const TravelPackageCardList({super.key, required this.travelPackagesList, required this.currentUserId});

  @override
  State<StatefulWidget> createState() {
    return  _TravelPackageCardListState();
  }
}

class _TravelPackageCardListState
    extends State<TravelPackageCardList> {

  @override
  Widget build(BuildContext context) {
    return widget.travelPackagesList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: widget.travelPackagesList.length,
            itemBuilder: (context, index) => TravelPackageCard(
            travelPackage    : widget.travelPackagesList[index], currentUserId: widget.currentUserId,),
          );
  }
}
