import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/refund_package_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';
import 'package:tripify/widgets/refund_application_card.dart';
import 'package:tripify/widgets/travel_package_card.dart';

class RefundApplicationCardList extends StatefulWidget {
  final List<RefundPackageModel> refundPackagesList;
  final String currentUserId;
  const RefundApplicationCardList({super.key, required this.refundPackagesList, required this.currentUserId});

  @override
  State<StatefulWidget> createState() {
    return _RefundApplicationCardListState();
  }
}

class _RefundApplicationCardListState
    extends State<RefundApplicationCardList> {

  @override
  Widget build(BuildContext context) {
    return widget.refundPackagesList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: widget.refundPackagesList.length,
            itemBuilder: (context, index) => RefundApplicationCard(
            refundPackage    : widget.refundPackagesList[index], currentUserId: widget.currentUserId,),
          );
  }
}
