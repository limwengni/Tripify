import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';
import 'package:tripify/widgets/travel_package_card.dart';
import 'package:tripify/widgets/travel_package_on_shelves_card.dart';
import 'package:tripify/widgets/travel_package_purchased_card.dart';

class TravelPackageOnShelvesCardList extends StatefulWidget {
  final List<TravelPackageModel> travelPackagesOnShelvesList;
  final String currentUserId;
  const TravelPackageOnShelvesCardList(
      {super.key,
      required this.travelPackagesOnShelvesList,
      required this.currentUserId});

  @override
  State<StatefulWidget> createState() {
    return _TravelPackageOnShelvesCardListState();
  }
}

class _TravelPackageOnShelvesCardListState
    extends State<TravelPackageOnShelvesCardList> {
  @override
  Widget build(BuildContext context) {
    // if (widget.travelPackagesPurchasedList == null)
    //   return const Center(child: CircularProgressIndicator());
    // else
    return ListView.builder(
        itemCount: widget.travelPackagesOnShelvesList.length,
        itemBuilder: (context, index) {
          var travelPackage = widget.travelPackagesOnShelvesList[index];
          return TravelPackageOnShelvesCard(
            travelPackageOnShelve:widget.travelPackagesOnShelvesList[index],
            currentUserId: widget.currentUserId,
          );
        });
  }
}
