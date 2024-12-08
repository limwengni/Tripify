import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/chat_page.dart';
import 'package:tripify/views/group_chat_create_page.dart';
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
  //search bar
  late TextEditingController _usernameController;
  String memberUsername = '';
  UserModel? foundUser;
  // List<Map<String, String>> members = [];
  List<UserModel>? userList = [];

  List<ConversationModel> conversationsList = [];
  final _allItems = [];

  @override
  void initState() {
    super.initState();
    fetchConversations();
    fetchAllUser();
  }

  void fetchAllUser() async {
    List<Map<String, dynamic>>? userListMap =
        await _firestoreService.getData('User');
    if (userListMap.isNotEmpty) {
      setState(() {
        userList = userListMap
            .map((userMap) => UserModel.fromMap(userMap, userMap['id']))
            .toList();
        print(userList.toString());
      });
    }
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) =>
                      GroupChatCreatePage(currentUserId: currentUserId)));
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor: const Color.fromARGB(255, 159, 118, 249),
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

                // Filter userList based on the search query
                final suggestions = userList!
                    .where((user) => user.username
                        .toLowerCase()
                        .contains(query.toLowerCase())) // Filter by name
                    .toList();

                return suggestions.isNotEmpty
                    ? suggestions.map((user) {
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: user.profilePic != null &&
                                    user.profilePic!.isNotEmpty
                                ? NetworkImage(
                                    user.profilePic!) // Use user's picture
                                : null,
                          ),
                          title: Text(user.username), // Display user name
                          // subtitle: Text(user.email), // Optional: Display user email
                          onTap: () async {
                            List<String> participants = [
                              currentUserId,
                              user.uid
                            ];
                            ConversationModel? conversation;
                            Map<String, dynamic>? conversationMap =
                                await _firestoreService.getFilteredDataDirectly(
                                    'Conversations',
                                    'participants',
                                    participants);
                            conversationMap =
                                await _firestoreService.getFilteredDataDirectly(
                                    'Conversations',
                                    'participants',
                                    participants);

                            if (conversationMap == null) {
                              ConversationModel conversationModel =
                                  ConversationModel(
                                id: '',
                                participants: participants,
                                isGroup: false,
                                updatedAt: DateTime.now(),
                                host: currentUserId,
                                unreadMessage: {
                                  participants[0]: 0,
                                  participants[1]: 0
                                },
                              );
                              await _firestoreService.insertDataWithAutoID(
                                  'Conversations', conversationModel.toMap());

                              conversationMap = await _firestoreService
                                  .getFilteredDataDirectly('Conversations',
                                      'participants', participants);

                              conversation =
                                  ConversationModel.fromMap(conversationMap!);
                            } else {
                              conversation =
                                  ConversationModel.fromMap(conversationMap!);
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (builder) => ChatPage(
                                        conversation: conversation!,
                                        currentUserId: currentUserId,
                                        chatPic: user.profilePic,
                                      )),
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

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.isEmpty) return [];

    final firestoreService = FirestoreService();

    // Query Firestore for users matching the search input
    final results = await firestoreService.queryData(
      collection: 'users',
      field:
          'name', // Adjust to the field you want to search, e.g., 'username' or 'email'
      query: query,
    );

    return results;
  }

  // Widget buildStep2() {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       TextFormField(
  //         controller: _usernameController,
  //         decoration: InputDecoration(
  //             labelText: 'Member Username', border: OutlineInputBorder()),
  //         onChanged: (value) {
  //           setState(() {
  //             memberUsername = value;
  //           });

  //           _searchUser(value);
  //         },
  //       ),
  //       if (foundUser != null)
  //         Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
  //           // Profile Picture and Username
  //           GestureDetector(
  //             onTap: () {
  //               setState(() {
  //                 if (!members.any(
  //                     (member) => member['username'] == foundUser?.username)) {
  //                   members.add({
  //                     'username': foundUser?.username ?? '',
  //                     'profilePic': foundUser?.profilePic ?? '',
  //                   });
  //                 }
  //                 foundUser = null;
  //                 memberUsername = '';
  //                 _usernameController.clear();
  //                 FocusScope.of(context).unfocus();
  //               });
  //             },
  //             child: Container(
  //                 padding: EdgeInsets.only(left: 5, right: 5, top: 14),
  //                 child: Row(
  //                   children: [
  //                     CircleAvatar(
  //                       backgroundImage:
  //                           NetworkImage(foundUser?.profilePic ?? ''),
  //                       radius: 26,
  //                     ),
  //                     SizedBox(width: 16),
  //                     Text(foundUser?.username ?? 'Username not found',
  //                         style: TextStyle(fontSize: 18)),
  //                   ],
  //                 )),
  //           ),
  //         ]),
  //       SizedBox(height: 20),
  //       Text(
  //         'Members to Invite:',
  //         style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  //       ),
  //       SizedBox(height: 14),
  //       Expanded(
  //         child: SingleChildScrollView(
  //           child: Column(
  //             children: members.map((member) {
  //               return Container(
  //                 padding: EdgeInsets.all(5),
  //                 margin:
  //                     EdgeInsets.only(bottom: 10), // Space between containers
  //                 child: Row(
  //                   mainAxisAlignment: MainAxisAlignment
  //                       .spaceBetween, // Space between username and icons
  //                   children: [
  //                     Row(
  //                       children: [
  //                         CircleAvatar(
  //                           backgroundImage:
  //                               NetworkImage(member['profilePic'] ?? ''),
  //                           radius: 26,
  //                         ),
  //                         SizedBox(width: 16),
  //                         Text(
  //                           member['username'] ?? 'Unknown User',
  //                           style: TextStyle(fontSize: 18),
  //                         ),
  //                       ],
  //                     ),
  //                     Row(
  //                       children: [
  //                         IconButton(
  //                           icon: Icon(Icons.remove, color: Colors.red),
  //                           onPressed: () {
  //                             setState(() {
  //                               members.remove(member);
  //                             });
  //                           },
  //                         ),
  //                       ],
  //                     ),
  //                   ],
  //                 ),
  //               );
  //             }).toList(),
  //           ),
  //         ),
  //       ),
  //       Row(
  //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //         children: [
  //           ElevatedButton(
  //             onPressed: () => setState(() => step = 1),
  //             style: ElevatedButton.styleFrom(
  //               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
  //               minimumSize: Size(150, 48),
  //               backgroundColor: Colors.blue,
  //             ),
  //             child: Text('Back', style: TextStyle(color: Colors.white)),
  //           ),
  //           ElevatedButton(
  //             onPressed: _nextStep,
  //             style: ElevatedButton.styleFrom(
  //               padding: EdgeInsets.symmetric(vertical: 8, horizontal: 24),
  //               minimumSize: Size(150, 48),
  //               backgroundColor: Color.fromARGB(255, 159, 118, 249),
  //             ),
  //             child: Text('Next', style: TextStyle(color: Colors.white)),
  //           ),
  //         ],
  //       )
  //     ],
  //   );
  // }

  // Future<void> _searchUser(String username) async {
  //   await _firestoreService.searchUser(username);

  //   setState(() {
  //     foundUser = firestoreService.userModel;
  //   });
  // }
}
