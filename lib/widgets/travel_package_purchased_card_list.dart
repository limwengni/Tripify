import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/models/travel_package_purchased_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';
import 'package:tripify/widgets/travel_package_card.dart';
import 'package:tripify/widgets/travel_package_purchased_card.dart';

class TravelPackagePurchasedCardList extends StatefulWidget {
  final List<TravelPackagePurchasedModel> travelPackagesPurchasedList;
  final String currentUserId;
  const TravelPackagePurchasedCardList(
      {super.key,
      required this.travelPackagesPurchasedList,
      required this.currentUserId});

  @override
  State<StatefulWidget> createState() {
    return _TravelPackagePurchasedCardListState();
  }
}

class _TravelPackagePurchasedCardListState
    extends State<TravelPackagePurchasedCardList> {
  @override
  Widget build(BuildContext context) {
    // if (widget.travelPackagesPurchasedList == null)
    //   return const Center(child: CircularProgressIndicator());
    // else
    return ListView.builder(
        itemCount: widget.travelPackagesPurchasedList.length,
        itemBuilder: (context, index) {
          var travelPackage = widget.travelPackagesPurchasedList[index];
          if (travelPackage == null) {
            return const Center(child: Text("No data available"));
          }
          return TravelPackagePurchasedCard(
            travelPackagePurchased: travelPackage,
            currentUserId: widget.currentUserId,
          );
        });
  }
}
