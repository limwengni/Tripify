import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/widgets/car_rental_requirement_card.dart';
import 'package:tripify/widgets/group_chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/widgets/group_chat_user_edit_card.dart';

class GroupChatUserEditCardList extends StatefulWidget {
  final List<UserModel> userList;
  final bool addToGroup;
  final ConversationModel conversation;
  final Function(ConversationModel) onConversationUpdated;
  final List<UserModel> addedUsers; // List of added users
  final Function(UserModel) onUserAdded;
  final Function(UserModel) onUserRemoved;

  const GroupChatUserEditCardList({
    super.key,
    required this.userList,
    required this.addToGroup,
    required this.conversation,
    required this.onConversationUpdated,
    required this.addedUsers,
    required this.onUserAdded,
    required this.onUserRemoved,
  });

  @override
  State<StatefulWidget> createState() {
    return _GroupChatUserEditCardListState();
  }
}

class _GroupChatUserEditCardListState extends State<GroupChatUserEditCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.userList.length,
      itemBuilder: (context, index) {
        // Only display users who have been added or are part of the conversation
        bool isAdded = widget.addedUsers.contains(widget.userList[index]);
        return GroupChatUserEditCard(
          conversation: widget.conversation,
          user: widget.userList[index],
          addToGroup: widget.addToGroup,
          onConversationUpdated: widget.onConversationUpdated,
          onUserAdded: widget.onUserAdded,
          onUserRemoved: widget.onUserRemoved,
        );
      },
    );
  }
}
