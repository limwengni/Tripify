import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/add_group_chat_user_page.dart';
import 'package:tripify/views/group_chat_edit_page.dart';
import 'package:tripify/widgets/group_chat_user_card.dart';
import 'package:tripify/widgets/group_chat_user_card_list.dart';

class GroupChatManagementPage extends StatefulWidget {
  ConversationModel conversation;
  List<UserModel> groupChatUserList;
  final Function(UserModel)
      onGroupMemberUpdated; // Callback to update the group user list
  final Function(String) onGroupNameUpdated;

  GroupChatManagementPage(
      {Key? key,
      required this.conversation,
      required this.groupChatUserList,
      required this.onGroupMemberUpdated,
      required this.onGroupNameUpdated})
      : super(key: key);

  @override
  _GroupChatManagementPageState createState() =>
      _GroupChatManagementPageState();
}

class _GroupChatManagementPageState extends State<GroupChatManagementPage> {
  FirestoreService _firestoreService = FirestoreService();
  List<UserModel> userCanbeAdded = [];
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.conversation.groupName!),
        ),
        body: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Center(
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Image inside ClipOval
                    ClipOval(
                      child: Image.network(
                        widget.conversation.conversationPic!,
                        width: 200,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Edit icon on top of the image
                    Positioned(
                      top: 10, // Position from the top
                      right: 10, // Position from the right
                      child: CircleAvatar(
                        backgroundColor: Colors.white
                            .withOpacity(0.7), // Semi-transparent background
                        child: IconButton(
                          icon: const Icon(
                            Icons.edit,
                            color: Colors.black, // Edit icon color
                          ),
                          onPressed: () {
                            // Handle edit functionality
                            print('Edit icon pressed');
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.conversation.groupName!,
                      style: const TextStyle(
                        fontSize: 25,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        _showEditDialog(context);
                      },
                      icon: Icon(Icons.edit),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 15,
                ),
                Row(
                  children: [
                    Text('Group Member:'),
                    Spacer(),
                    IconButton(
                      onPressed: () async {
                        // Fetch data from Firestore
                        List<Map<String, dynamic>> data =
                            await _firestoreService.getData("User");
                        print(data);

                        // Convert to user model list
                        List<UserModel> fetchedUsers = data.map((item) {
                          return UserModel.fromMap(item, item['id']);
                        }).toList();

                        // Remove users already in the group
                        fetchedUsers.removeWhere((user) => widget
                            .groupChatUserList
                            .any((userInGroup) => user.uid == userInGroup.uid));

                        if (mounted) {
                          setState(() {
                            userCanbeAdded = fetchedUsers;
                          });
                        }

                        if (mounted) {
                          Navigator.push(
                            // ignore: use_build_context_synchronously
                            context,
                            MaterialPageRoute(
                              builder: (builder) => AddGroupChatUserPage(
                                userList: userCanbeAdded,
                                addToGroup: true,
                                conversation: widget.conversation,
                                onGroupUpdated: _updateGroupChatUserList,
                              ),
                            ),
                          );
                        }
                      },
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                Expanded(
                    child: GroupChatUserCardList(
                  userList: widget.groupChatUserList,
                  conversation: widget.conversation,
                  addToGroup: false,
                  onConversationUpdated: updateConversation,
                ))
              ],
            ),
          ),
        ));
  }

  void _showEditDialog(BuildContext context) {
    TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit group name'),
          content: TextField(
            controller: _controller,
            decoration: InputDecoration(
                hintText: 'Enter new group name here',
                hintStyle: TextStyle(color: Colors.grey[500])),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                // Handle the input here
                String inputText = _controller.text;
                print('User input: $inputText');
                ConversationModel updatedConversation = widget.conversation;
                updatedConversation.updateGroupName(inputText);
                await _firestoreService.updateData("Conversations",
                    widget.conversation.id, updatedConversation.toMap());
                setState(() {
                  widget.conversation = updatedConversation;
                });
                widget.onGroupNameUpdated(widget.conversation.groupName!);

                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Submit'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _updateGroupChatUserList(List<UserModel> updatedUserList) {
    setState(() {
      widget.groupChatUserList
          .addAll(updatedUserList); // Update the group chat user list
    });
  }

  void updateConversation(ConversationModel updatedConversation) {
    setState(() {
      widget.conversation = updatedConversation;
      _getGroupChatUser(updatedConversation.participants);
    });
  }

  void _getGroupChatUser(List<String> participantsId) async {
    Map<String, dynamic>? user;
    List<Map<String, dynamic>?> groupChatUser = [];

    for (var userId in participantsId) {
      user = await _firestoreService.getDataById("User", userId);
      if (user != null) {
        groupChatUser.add(user);
      } else {
        print("User data not found for userId: $userId");
      }
    }

    setState(() {
      if (groupChatUser != null) {
        widget.groupChatUserList = groupChatUser.map((item) {
          return UserModel.fromMap(item!, item['id'] ?? '');
        }).toList();
      } else {
        print('no groupchatuserlist');
      }
    });
  }
}
