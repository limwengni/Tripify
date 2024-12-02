import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/group_chat_user_card_list.dart';
import 'package:tripify/widgets/group_chat_user_edit_card_list.dart';

class AddGroupChatUserPage extends StatefulWidget {
  final List<UserModel> userList;
  ConversationModel conversation;
  final Function(List<UserModel>)
      onGroupUpdated; // Callback to update the group user list

  final bool addToGroup;
  AddGroupChatUserPage(
      {Key? key,
      required this.userList,
      required this.addToGroup,
      required this.conversation,
      required this.onGroupUpdated})
      : super(key: key);

  @override
  _AddGroupChatUserPageState createState() => _AddGroupChatUserPageState();
}

class _AddGroupChatUserPageState extends State<AddGroupChatUserPage> {
  List<UserModel> addedUsers = []; // Track added users
  TextEditingController searchController = TextEditingController();
  void updateConversation(ConversationModel updatedConversation) {
    setState(() {
      widget.conversation = updatedConversation;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Group Chat User')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Your search widget
            const SizedBox(height: 10),
            Expanded(
              child: GroupChatUserEditCardList(
                userList: widget.userList, // Use full user list
                addToGroup: widget.addToGroup,
                conversation: widget.conversation,
                onConversationUpdated: updateConversation,
                addedUsers:
                    addedUsers, // Pass the added users to the child widget
                onUserAdded: (UserModel user) {
                  setState(() {
                    addedUsers.add(user); // Add the user to the list
                  });
                },
                onUserRemoved: (UserModel user) {
                  setState(() {
                    addedUsers.remove(user); // Remove the user from the list
                  });
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Pass the updated user list back to the parent
                widget.onGroupUpdated(addedUsers);

                // Navigate back to the previous page
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}
