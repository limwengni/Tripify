// import 'package:flutter/material.dart';
// import 'package:tripify/models/conversation_model.dart';
// import 'package:tripify/widgets/car_rental_requirement_card.dart';
// import 'package:tripify/widgets/conversation_card.dart';

// class ConversationCardList extends StatefulWidget {
//   final List<ConversationModel> conversationList;
//   const ConversationCardList({super.key, required this.conversationList});

//   @override
//   State<StatefulWidget> createState() {
//     return _CarRentalRequirementCardListState();
//   }
// }

// class _CarRentalRequirementCardListState
//     extends State<ConversationCardList> {

//   @override
//   Widget build(BuildContext context) {
//     return widget.conversationList.isEmpty
//         ? const Center(child: CircularProgressIndicator())
//         : ListView.builder(
//             itemCount: widget.conversationList.length,
//             itemBuilder: (context, index) => ConversationCard(
//                conversation: widget.conversationList[index]),
//           );
//   }
// }
