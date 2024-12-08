import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/widgets/group_chat_user_edit_card_list.dart';

class AddGroupChatUserPage extends StatefulWidget {
  final List<UserModel> userList;
  ConversationModel conversation;
  final Function(List<UserModel>) onGroupUpdated;
  final bool addToGroup;

  AddGroupChatUserPage({
    Key? key,
    required this.userList,
    required this.addToGroup,
    required this.conversation,
    required this.onGroupUpdated,
  }) : super(key: key);

  @override
  _AddGroupChatUserPageState createState() => _AddGroupChatUserPageState();
}

class _AddGroupChatUserPageState extends State<AddGroupChatUserPage> {
  List<UserModel> addedUsers = [];
  TextEditingController searchController = TextEditingController();
  List<UserModel> filteredUserList = [];
  FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    filteredUserList = widget.userList; // Initialize filtered list
    searchFocusNode.addListener(_onSearchFocusChange);
  }

  @override
  void dispose() {
    searchFocusNode.removeListener(_onSearchFocusChange);
    searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchFocusChange() {
    setState(() {
      // Rebuild the widget based on focus change
    });
  }

  void updateConversation(ConversationModel updatedConversation) {
    setState(() {
      widget.conversation = updatedConversation;
    });
  }

  void filterUsers(String query) {
    final lowerCaseQuery = query.toLowerCase();
    setState(() {
      filteredUserList = widget.userList.where((user) {
        final userName = user.username?.toLowerCase() ?? '';
        return userName.contains(lowerCaseQuery);
      }).toList();
    });
  }

  // Method to clear added users when the page is popped
  Future<bool> _onWillPop() async {
    setState(() {
      addedUsers.clear(); // Clear the added users
      widget.onGroupUpdated(addedUsers);
    });
    return true; // Allow the pop action to proceed
  }

  @override
  Widget build(BuildContext context) {
    bool isSearchFocused = searchFocusNode.hasFocus; // Check if search bar is focused

    return WillPopScope(
      onWillPop: _onWillPop, // Trigger clear action on pop
      child: Scaffold(
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

              // Table for added users - Only show when search bar is not focused
              if (!isSearchFocused)
                SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200, // Set the background color for the whole table
                      borderRadius: BorderRadius.circular(16.0), // Set the circular border radius
                      border: Border.all(color: Colors.grey), // Set the border color
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
                          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
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
                child: GroupChatUserEditCardList(
                  userList: filteredUserList,
                  addToGroup: widget.addToGroup,
                  conversation: widget.conversation,
                  onConversationUpdated: updateConversation,
                  addedUsers: addedUsers,
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
                  onPressed: () {
                    widget.onGroupUpdated(addedUsers);
                    Navigator.of(context).pop();
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
                    'Save',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
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
