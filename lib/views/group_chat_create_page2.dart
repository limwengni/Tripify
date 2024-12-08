import 'dart:io';

import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/group_chat_page.dart';
import 'package:tripify/widgets/group_chat_add_user_card_list.dart';
import 'package:tripify/widgets/group_chat_user_edit_card_list.dart';

class GroupChatCreatePage2 extends StatefulWidget {
  final File groupChatPic;
  final String currentUserId;
  final String groupName;

  GroupChatCreatePage2({
    Key? key,
    required this.currentUserId,
    required this.groupChatPic,
    required this.groupName,
  }) : super(key: key);
  @override
  _GroupChatCreatePage2State createState() => _GroupChatCreatePage2State();
}

class _GroupChatCreatePage2State extends State<GroupChatCreatePage2> {
  List<UserModel> addedUsers = [];
  TextEditingController searchController = TextEditingController();
  List<UserModel> filteredUserList = [];
  List<UserModel> userList = [];
  FocusNode searchFocusNode = FocusNode();
  FirestoreService _firestoreService = FirestoreService();
  FirebaseStorageService _firebaseStorageService = FirebaseStorageService();
  @override
  void initState() {
    super.initState();
    getFilteredList();
    searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    searchFocusNode.removeListener(_onSearchFocusChange);
    searchFocusNode.dispose();
    super.dispose();
  }

  void getFilteredList() async {
    List<Map<String, dynamic>> userListMap =
        await _firestoreService.getData('User');

    userList = userListMap
        .map((user) => UserModel.fromMap(
            user, user['id'])) // Convert each map to a UserModel object
        .where((user) =>
            user.uid != widget.currentUserId) // Filter out the currentUserId
        .toList();
    filteredUserList = userList;
    filterUsers(""); // Pass empty string to show all users
  }

  void _onSearchFocusChange() {
    setState(() {
      // Rebuild the widget based on focus change
    });
  }

  void filterUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredUserList = userList.where((user) {
        final userName = user.username?.toLowerCase() ?? '';
        return userName.contains(lowerCaseQuery);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isSearchFocused =
        searchFocusNode.hasFocus; // Check if search bar is focused

    return Scaffold(
      appBar: AppBar(title: const Text('Add Group Chat User')),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          children: [
            // Search bar
            TextField(
              controller: searchController,
              focusNode: searchFocusNode, // Attach the FocusNode
              onChanged: filterUsers,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Search users...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
            const SizedBox(height: 10),

            if (!isSearchFocused)
              SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey
                        .shade200, // Set the background color for the whole table
                    borderRadius: BorderRadius.circular(
                        16.0), // Set the circular border radius
                    border:
                        Border.all(color: Colors.grey), // Set the border color
                  ),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 200.0, // Maximum height for 2 rows
                    ),
                    child: SingleChildScrollView(
                      child: Table(
                        columnWidths: const {
                          0: FlexColumnWidth(1),
                          1: FlexColumnWidth(1),
                          2: FlexColumnWidth(1),
                        },
                        defaultVerticalAlignment:
                            TableCellVerticalAlignment.middle,
                        children: [
                          for (int i = 0; i < addedUsers.length; i += 4)
                            TableRow(
                              children: [
                                for (int j = 0; j < 4; j++)
                                  if (i + j < addedUsers.length)
                                    _buildUserCell(addedUsers[i + j])
                                  else
                                    const SizedBox(), // Empty cell if no user
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            const SizedBox(height: 10),

            // User list
            Expanded(
              child: GroupChatAddUserCardList(
                userList: filteredUserList,
                addToGroup: true,
                onUserAdded: (UserModel user) {
                  setState(() {
                    addedUsers.add(user);
                  });
                },
                onUserRemoved: (UserModel user) {
                  setState(() {
                    addedUsers.remove(user);
                  });
                },
              ),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (addedUsers.length > 1 && addedUsers.isNotEmpty) {
                    List<String> userIds =
                        addedUsers.map((user) => user.uid).toList();
                    userIds.add(widget.currentUserId);

                    Map<String, int> userUnreadMsgMap = Map.fromIterable(
                      userIds,
                      key: (userId) => userId,
                      value: (userId) => 0,
                    );

                    ConversationModel conversation = ConversationModel(
                        id: '',
                        participants: userIds,
                        isGroup: true,
                        groupName: widget.groupName,
                        updatedAt: DateTime.now(),
                        host: widget.currentUserId,
                        unreadMessage: userUnreadMsgMap);
                    String conversationId =
                        await _firestoreService.insertDataWithReturnAutoID(
                            'Conversations', conversation.toMap());

                    String? imgDownloadUrl =
                        await _firebaseStorageService.saveImageVideoToFirestore(
                            file: widget.groupChatPic,
                            storagePath: '${conversationId}');

                    await _firestoreService.updateField('Conversations',
                        conversationId, 'conversation_pic', imgDownloadUrl);

                    Map<String, dynamic>? conversationCreatedMap =
                        await _firestoreService.getDataById(
                            'Conversations', conversationId);
                    if (conversationCreatedMap != null) {
                      ConversationModel conversationCreated =
                          ConversationModel.fromMap(conversationCreatedMap);
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => GroupChatPage(
                                  conversation: conversationCreated,
                                  currentUserId: widget.currentUserId,
                                  chatPic:
                                      conversationCreated.conversationPic!)));
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select more than 1 member.'),
                        backgroundColor: Colors.red,
                      ),
                    );
                    return;
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                  textStyle: const TextStyle(fontSize: 16),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Create',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserCell(UserModel user) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: user.profilePic != null
                ? NetworkImage(user.profilePic!)
                : const AssetImage('assets/default_profile.png')
                    as ImageProvider,
            radius: 25,
          ),
          const SizedBox(height: 5),
          Text(
            user.username ?? 'Unknown User',
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
