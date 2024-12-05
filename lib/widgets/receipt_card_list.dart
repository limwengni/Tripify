import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/receipt_model.dart';
import 'package:tripify/models/travel_package_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';
import 'package:tripify/widgets/receipt_card.dart';
import 'package:tripify/widgets/travel_package_card.dart';

class ReceiptCardList extends StatefulWidget {
  final List<ReceiptModel> receiptList;
  final String currentUserId;
  const ReceiptCardList({super.key, required this.receiptList, required this.currentUserId});

  @override
  State<StatefulWidget> createState() {
    return  _ReceiptCardListState();
  }
}

class _ReceiptCardListState
    extends State<ReceiptCardList> {

  @override
  Widget build(BuildContext context) {
    return widget.receiptList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: widget.receiptList.length,
            itemBuilder: (context, index) => ReceiptCard(
          receipt  : widget.receiptList[index], currentUserId: widget.currentUserId,),
          );
  }
}
