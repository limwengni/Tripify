import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/widgets/car_rental_requirement_card.dart';
import 'package:tripify/widgets/group_chat_user_card.dart';

class GroupChatUserCardList extends StatefulWidget {
  final List<UserModel> userList;
  final Function(ConversationModel) onConversationUpdated;
  final ConversationModel conversation;

  const GroupChatUserCardList(
      {super.key,
      required this.userList,
      required this.conversation,
      required this.onConversationUpdated});

  @override
  State<StatefulWidget> createState() {
    return _GroupChatUserCardListState();
  }
}

class _GroupChatUserCardListState extends State<GroupChatUserCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.userList.length,
      itemBuilder: (context, index) => GroupChatUserCard(
        conversation: widget.conversation,
        user: widget.userList[index],
        addToGroup: false,
        onConversationUpdated: widget.onConversationUpdated,
      ),
    );
  }
}