import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/widgets/car_rental_requirement_card.dart';
import 'package:tripify/widgets/group_chat_add_user_card.dart';
import 'package:tripify/widgets/group_chat_user_card.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/widgets/group_chat_user_edit_card.dart';

class GroupChatAddUserCardList extends StatefulWidget {
  final List<UserModel> userList;
  final bool addToGroup;
  final Function(UserModel) onUserAdded;
  final Function(UserModel) onUserRemoved;

  const GroupChatAddUserCardList({
    super.key,
    required this.userList,
    required this.addToGroup,
    required this.onUserAdded,
    required this.onUserRemoved,
  });

  @override
  State<StatefulWidget> createState() {
    return _GroupChatAddUserCardListState();
  }
}

class _GroupChatAddUserCardListState extends State<GroupChatAddUserCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: widget.userList.length,
      itemBuilder: (context, index) {
        return GroupChatAddUserCard(
          user: widget.userList[index],
          addToGroup: widget.addToGroup,
          onUserAdded: widget.onUserAdded,
          onUserRemoved: widget.onUserRemoved,
        );
      },
    );
  }
}
