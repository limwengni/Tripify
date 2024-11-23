import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/group_chat_user_card_list.dart';

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
  // Example state variable
  List<String> userCanBeAdded = [];
  TextEditingController searchController = TextEditingController();
  FirestoreService _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    // Initialize any data or start any services
    userCanBeAdded = ["User 1", "User 2", "User 3"]; // Sample data
  }

  @override
  void dispose() {
    // Clean up resources, such as controllers
    searchController.dispose();
    super.dispose();
  }

  void updateConversation(ConversationModel updatedConversation) {
    setState(() {
      widget.conversation = updatedConversation;
    });
  }

  @override
  Widget build(BuildContext context) {
    final _allItems = ['A', 'B', 'C'];
    final SearchController controller = SearchController();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Group Chat User'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Center(
          child: Column(
            children: [
              SearchAnchor(
                searchController: controller,
                viewHintText: 'Search...',
                viewTrailing: [
                  IconButton(
                    onPressed: () {
                      controller.closeView(controller.text);
                    },
                    icon: const Icon(Icons.search),
                  ),
                  IconButton(
                    onPressed: () {
                      controller.clear();
                    },
                    icon: const Icon(Icons.clear),
                  ),
                ],
                builder: (context, controller) {
                  return SearchBar(
                    controller: controller,
                    leading: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        controller.openView();
                      },
                    ),
                    hintText: 'Search...',
                    onTap: () => controller.openView(),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  final query = controller.value.text;
                  final suggestions = _allItems
                      .where((item) =>
                          item.toLowerCase().contains(query.toLowerCase()))
                      .toList();

                  return suggestions.isNotEmpty
                      ? suggestions.map((suggestion) {
                          return ListTile(
                            title: Text(suggestion),
                            onTap: () {
                              controller.closeView(suggestion);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                    content: Text('You selected $suggestion')),
                              );
                            },
                          );
                        }).toList()
                      : [const ListTile(title: Text('No results found'))];
                },
              ),
              const SizedBox(height: 10),
              Expanded(
                child: GroupChatUserCardList(
                  userList: widget.userList,
                  addToGroup: widget.addToGroup,
                  conversation: widget.conversation,
                  onConversationUpdated:
                      updateConversation, // Pass the callback
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: MaterialButton(
                  padding: const EdgeInsets.all(15),
                  color: Theme.of(context).colorScheme.secondary,
                  onPressed: () async {
                    await _firestoreService.updateData("Conversations",
                        widget.conversation.id, widget.conversation.toMap());
                        
                    widget.onGroupUpdated(widget.userList);

                    Navigator.pop(context,
                        'Accommodation requirement created successfully');
                  },
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
}
