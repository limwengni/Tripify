import 'package:flutter/material.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/widgets/accommodation_requirement_card.dart';
import 'package:tripify/widgets/cashout_card.dart';

class CashoutCardList extends StatefulWidget {
  final List<CashoutApplicationModel> cashoutList;
  const CashoutCardList({super.key, required this.cashoutList});

  @override
  State<StatefulWidget> createState() {
    return _CashoutCardListState();
  }
}

class _CashoutCardListState extends State<CashoutCardList> {
  @override
  Widget build(BuildContext context) {
    return widget.cashoutList.isEmpty
        ? const Center(child: CircularProgressIndicator())
        : ListView.builder(
            itemCount: widget.cashoutList.length,
            itemBuilder: (context, index) =>
                CashoutCard(cashoutApplication: widget.cashoutList[index]),
          );
  }
}
