import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
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
  final Function(String) onGroupImageUpdated;

  GroupChatManagementPage(
      {Key? key,
      required this.conversation,
      required this.groupChatUserList,
      required this.onGroupMemberUpdated,
      required this.onGroupNameUpdated,
      required this.onGroupImageUpdated})
      : super(key: key);

  @override
  _GroupChatManagementPageState createState() =>
      _GroupChatManagementPageState();
}

class _GroupChatManagementPageState extends State<GroupChatManagementPage> {
  FirestoreService _firestoreService = FirestoreService();
  List<UserModel> userCanbeAdded = [];

  final ImagePicker picker = ImagePicker();
  XFile? _imageSelected;

  @override
  void initState() {
    super.initState();
  }

  void _updateGroupChatUserList(List<UserModel> updatedUserList) async {
    setState(() {
      // Add the new users to the group chat user list
      widget.groupChatUserList.addAll(updatedUserList);
    });
    List<String> userIds = widget.groupChatUserList
    .map((user) => user.uid) // Extract the id from each UserModel
    .toList(); // Convert it to a List<String>

print(userIds);
    await _firestoreService.updateField('Conversations', widget.conversation.id,
        'participants', userIds);
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
                      child: widget.conversation.conversationPic != ''
                          ? Image.network(
                              widget.conversation.conversationPic!,
                              width: 180,
                              height: 180,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              width: 180,
                              height: 180,
                              color:
                                  Colors.grey, // Fallback color or placeholder
                              child: const Icon(
                                Icons.person,
                                size: 80,
                                color: Colors.white,
                              ),
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
                          onPressed: () async {
                           

                            FirebaseStorageService _firebaseStorageService =
                                FirebaseStorageService();

                            final XFile? groupchatPic = await picker.pickImage(
                                source: ImageSource.gallery);
                            
                            if (groupchatPic != null) {
                              File image = File(groupchatPic.path);
                              String? imgDownloadUrl = await _firebaseStorageService
                                  .saveImageVideoToFirestore(
                                      file: image,
                                      storagePath:
                                          '${widget.conversation.id}/groupchatPic/');
                              await _firestoreService.updateField(
                                  'Conversations',
                                  widget.conversation.id,
                                  'conversation_pic',
                                  imgDownloadUrl);

                              ConversationModel updatedConversation =
                                  widget.conversation;
                            
                              updatedConversation
                                  .updateGroupPic(imgDownloadUrl!);
                            
                              await _firestoreService.updateData(
                                  "Conversations",
                                  widget.conversation.id,
                                  updatedConversation.toMap());
                            
                              setState(() {
                                widget.conversation = updatedConversation;
                              });
                            
                              widget.onGroupImageUpdated(
                                  widget.conversation.conversationPic!);
                            }
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
                            context,
                            MaterialPageRoute(
                              builder: (builder) => AddGroupChatUserPage(
                                userList: userCanbeAdded,
                                addToGroup: true,
                                conversation: widget.conversation,
                                onGroupUpdated:
                                    _updateGroupChatUserList, // Pass the callback here
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
