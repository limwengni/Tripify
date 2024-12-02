import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/chat_page.dart';
import 'package:tripify/views/group_chat_page.dart';
import 'package:tripify/widgets/conversation_card.dart';
import 'package:tripify/widgets/conversation_card_list.dart';
import 'package:tripify/widgets/conversation_tile.dart';

class ChatListPage extends StatefulWidget {
  const ChatListPage({super.key});

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ConversationModel> conversationsList = [];
  final _allItems = ['A', 'B', 'C'];

  @override
  void initState() {
    super.initState();
    fetchConversations();
  }

  Future<void> fetchConversations() async {
    FirestoreService firestoreService = FirestoreService();
    List<Map<String, dynamic>> data =
        await firestoreService.getData('Conversations');

    // Parse the data into your model
    if (mounted) {
      setState(() {
        conversationsList =
            data.map((item) => ConversationModel.fromMap(item)).toList();
      });
    }
  }

  final FirestoreService _firestoreService = FirestoreService();
  final currentUserId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final SearchController controller = SearchController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversations'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: SearchAnchor(
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
          ),
          Expanded(child: _buildConversationList()),
        ],
      ),
    );
  }

  Widget _buildConversationList() {
    return StreamBuilder<List<Map<String, dynamic>>>(
      stream: _firestoreService.getConversationsStream(currentUserId),
      builder: (context, snapshot) {
        // Handle error state
        if (snapshot.hasError) {
          return const Text("Error");
        }

        // Handle loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading...");
        }

        // Check if data is null or empty
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Text("No conversations found");
        }

        // Map to ConversationModel
        final List<ConversationModel> conversations = snapshot.data!
            .map<ConversationModel>((conversationData) =>
                ConversationModel.fromMap(conversationData))
            .toList();

        return ListView.builder(
          itemCount: conversations.length,
          itemBuilder: (context, index) {
            return _buildConversationListItem(
                conversations[index], context, currentUserId);
          },
        );
      },
    );
  }

  Widget _buildConversationListItem(
      ConversationModel conversation, BuildContext context, currentUserId) {
    // Safely handle null values for conversationPic (assuming this might be null)
    String conversationPic =
        conversation.conversationPic ?? ''; // Default to empty string if null

    return ConversationTile(
      currentUserId: currentUserId,
      onTap: (conversationPic) {
        if (conversation.isGroup ?? false) {
          // Use null-aware operator to prevent null check errors
          conversation.clearUnreadMessage(currentUserId);

          _firestoreService.updateData(
              "Conversations", conversation.id, conversation.toMap());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => GroupChatPage(
                conversation: conversation,
                currentUserId: currentUserId,
                chatPic: conversationPic,
              ),
            ),
          );
        } else {
          conversation.clearUnreadMessage(currentUserId);
          _firestoreService.updateData(
              "Conversations", conversation.id, conversation.toMap());
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (builder) => ChatPage(
                conversation: conversation,
                currentUserId: currentUserId,
                chatPic: conversationPic,
              ),
            ),
          );
        }
      },
      conversation: conversation,
    );
  }
}
