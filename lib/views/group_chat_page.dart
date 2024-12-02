import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/message_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/conversation_view_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/create_poll_page.dart';
import 'package:tripify/views/group_chat_management_page.dart';
import 'package:tripify/widgets/chat_bubble.dart';
import 'package:tripify/widgets/pin_message.dart';

class GroupChatPage extends StatefulWidget {
  ConversationModel conversation;
  final String currentUserId;
  String chatPic;

  GroupChatPage(
      {Key? key,
      required this.conversation,
      required this.currentUserId,
      required this.chatPic})
      : super(key: key);

  @override
  _GroupChatPageState createState() => _GroupChatPageState();
}

class _GroupChatPageState extends State<GroupChatPage> {
  FirestoreService _firestoreService = FirestoreService();
  FirebaseStorageService _firebaseStorageService = FirebaseStorageService();
  final TextEditingController _messageController = TextEditingController();
  final ConversationViewModel _conversationViewModel = ConversationViewModel();
  String appBarTitle = "Loading...";
  bool extraAction = false;
  final ValueNotifier<bool> _extraActionNotifier = ValueNotifier<bool>(false);
  List<Map<String, dynamic>?> groupChatUser = [];
  Map<String, dynamic>? user;
  List<UserModel>? groupChatUserList = [];

  final ImagePicker picker = ImagePicker();
  XFile? _imageSelected;
  String? fileName;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setAppBarTitle();
    _getGroupChatUser(widget.conversation.participants);
  }

  Future<void> _setAppBarTitle() async {
    if (widget.conversation.isGroup) {
      // Group chat: Use the group name
      setState(() {
        appBarTitle = widget.conversation.groupName ?? "Group Chat";
      });
    } else {
      // One-on-one chat: Fetch the other participant's username from Firestore
      String otherParticipantId = widget.conversation.participants.firstWhere(
        (id) => id != widget.currentUserId,
        orElse: () => "",
      );

      if (otherParticipantId.isNotEmpty) {
        try {
          DocumentSnapshot userDoc = await FirebaseFirestore.instance
              .collection('User') // Replace with your users collection
              .doc(otherParticipantId)
              .get();

          if (userDoc.exists) {
            setState(() {
              appBarTitle = userDoc['username'] ??
                  "Unknown User"; // Replace 'username' with your field name
            });
          } else {
            setState(() {
              appBarTitle = "Unknown User";
            });
          }
        } catch (e) {
          setState(() {
            appBarTitle = "Error loading username";
          });
          print("Error fetching user data: $e");
        }
      }
    }
  }

  void _getGroupChatUser(List<String> participantsId) async {
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
        groupChatUserList = groupChatUser.map((item) {
          return UserModel.fromMap(item!, item['id'] ?? '');
        }).toList();

        print(groupChatUserList![1].profilePic);
      } else {
        print('no groupchatuserlist');
      }
    });
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _conversationViewModel.sendMessage(
          senderID: widget.currentUserId,
          content: _messageController.text,
          contentType: ContentType.text,
          conversation: widget.conversation);

      // Clear the message input
      setState(() {
        _messageController.clear();
      });
    }
  }

  void changeExtraAction() {
    _extraActionNotifier.value = !_extraActionNotifier.value;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _extraActionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await _firestoreService.updateMapField('Conversations',
            widget.conversation.id, 'unread_message', widget.currentUserId, 0);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
            title: Row(
              children: [
                ClipOval(
                  child: widget.chatPic != ''
                      ? Image.network(
                          widget.chatPic,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                        )
                      : Container(
                          width: 40,
                          height: 40,
                          color: Colors.grey, // Fallback color or placeholder
                          child: Icon(
                            Icons.person,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(appBarTitle)
              ],
            ),
            actions: [
              IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (builder) => GroupChatManagementPage(
                            conversation: widget.conversation,
                            groupChatUserList: groupChatUserList!,
                            onGroupMemberUpdated: _updateGroupChatUserList,
                            onGroupNameUpdated: _updateGroupName,
                            onGroupImageUpdated: _updatedGroupPic,
                          ),
                        ));
                  },
                  icon: const Icon(Icons.more_vert_outlined)),
            ]),
        body: Column(
          children: [
            if (widget.conversation.messagePinnedId != null)
              _buildPinMessage(widget.conversation.id),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  top: 0.0,
                  left: 15.0,
                  right: 15.0,
                  bottom: 15.0,
                ),
                child: _buildMessageList(widget.conversation.id),
              ),
            ),
            _buildUserInput(widget.currentUserId, widget.conversation.id)
          ],
        ),
      ),
    );
  }

  Widget _buildPinMessage(String conversationId) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _conversationViewModel.getConversationStream(
          conversationId: widget.conversation.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text('Error fetching pinned message');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // Check if the document exists and has the pinned message
        var document = snapshot.data;
        if (document != null && document.exists) {
          // Assuming you store the pinned message in a field 'pinnedMessage'
          String pinnedMessage = document['message_pinned_id'] ?? '';

          // If there's a pinned message, display it using PinMessage
          if (pinnedMessage.isNotEmpty) {
            return PinMessage(message: pinnedMessage);
          } else {
            return const Text('No pinned message');
          }
        }

        return const Text('Conversation not found');
      },
    );
  }

  Widget _buildMessageList(String conversationId) {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    return StreamBuilder(
        stream:
            _conversationViewModel.getMessages(conversationId: conversationId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text('error');
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Text('Loading...');
          }
          WidgetsBinding.instance.addPostFrameCallback((_) {
            // Scroll to the bottom when new messages arrive
            if (_scrollController.hasClients) {
              _scrollController
                  .jumpTo(_scrollController.position.minScrollExtent);
            }
          });
          return ListView(
            controller: _scrollController,
            reverse: true, // Show the latest messages at the bottom
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildMessageItem(doc, currentUserId))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc, String currentUserId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['sender_id'] == currentUserId;
    MessageModel messageModel = MessageModel.fromMap(data);

    return Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          message: data['content'],
          isCurrentUser: isCurrentUser,
          createdAt: data['created_at'].toDate(),
          contentType: data['content_type'],
          fileName: data['file_name'],
          senderId: data['sender_id'],
          isGroup: widget.conversation.isGroup,
          conversation: widget.conversation,
          currentUser: currentUserId,
          messageModel: messageModel,
        ),
        const SizedBox(
          height: 5,
        ),
      ],
    );
  }

  String? getSenderName(String senderId, List<UserModel> groupChatUserList) {
    for (var user in groupChatUserList) {
      if (user.uid == senderId) {
        return user.username;
      }
    }
    return null; // Return null if no match is found
  }

  Widget _buildUserInput(String currentUserId, String conversationId) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 236, 236, 236),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(15.0),
        ),
      ),
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Only rebuild this part when `extraActionNotifier` changes
          ValueListenableBuilder<bool>(
            valueListenable: _extraActionNotifier,
            builder: (context, extraAction, child) {
              if (!extraAction) return const SizedBox.shrink();

              return Table(
                children: [
                  TableRow(
                    children: [
                      // _buildActionItem(
                      //     Icons.camera_alt_outlined, 'Camera', () async {}),
                      _buildActionItem(Icons.file_present_outlined, 'File',
                          () async {
                        FilePickerResult? result = await FilePicker.platform
                            .pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                                allowMultiple: true);
                        if (result != null) {
                          for (var pickedFile in result.files) {
                            if (pickedFile.path != null) {
                              File file = File(pickedFile.path!);
                              String pdfFileName = pickedFile
                                  .name; // This gives you the name of the file
                              String? pdfDownloadUrl =
                                  await _firebaseStorageService.saveToFirestore(
                                      file: file, storagePath: conversationId);

                              _conversationViewModel.sendMessage(
                                senderID: currentUserId,
                                content: pdfDownloadUrl!,
                                contentType: ContentType.file,
                                conversation: widget.conversation,
                                fileName: pdfFileName,
                              );
                            }
                          }
                        } else {
                          // No file selected
                          print("No files selected");
                        }
                      }),
                      _buildActionItem(
                        Icons.photo_library_outlined,
                        'Gallery',
                        () async {
                          final List<XFile> mediaFiles = await picker
                              .pickMultipleMedia(requestFullMetadata: false);

                          if (mediaFiles != null) {
                            for (var file in mediaFiles) {
                              final String extension =
                                  file.path.split('.').last.toLowerCase();

                              if (['jpg', 'jpeg', 'png', 'gif']
                                  .contains(extension)) {
                                String? imgDownloadUrl =
                                    await _firebaseStorageService
                                        .saveImageVideoToFirestore(
                                            file: File(file.path),
                                            storagePath: conversationId);

                                _conversationViewModel.sendMessage(
                                    senderID: currentUserId,
                                    content: imgDownloadUrl!,
                                    contentType: ContentType.pic,
                                    conversation: widget.conversation);
                              } else if (['mp4', 'mov', 'avi', 'mkv']
                                  .contains(extension)) {
                                String? videoDownloadUrl =
                                    await _firebaseStorageService
                                        .saveImageVideoToFirestore(
                                            file: File(file.path),
                                            storagePath: conversationId);

                                _conversationViewModel.sendMessage(
                                  senderID: currentUserId,
                                  content: videoDownloadUrl!,
                                  contentType: ContentType.video,
                                  conversation: widget.conversation,
                                );
                              }
                            }
                          } else {
                            print('No media selected');
                          }
                        },
                      ),
                      _buildActionItem(Icons.add_chart, 'Poll', () async {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (builder) => CreatePollPage(
                                      currentUserId: widget.currentUserId,
                                      conversation: widget.conversation,
                                    )));
                      }),
                    ],
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(width: 5),
              IconButton(
                onPressed: changeExtraAction,
                icon: const Icon(Icons.add),
              ),
              const SizedBox(width: 5),
              Container(
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: sendMessage,
                  icon: const Icon(Icons.arrow_upward, color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem(IconData icon, String label, Function() onPressed) {
    return Column(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.grey,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 2),
        Text(label),
      ],
    );
  }

  void _updateGroupChatUserList(UserModel userRemoved) {
    setState(() {
      groupChatUserList!.remove(userRemoved);
    });
  }

  void _updateGroupName(String newGroupName) {
    setState(() {
      appBarTitle = newGroupName;
      widget.conversation.updateGroupName(newGroupName);
    });
  }

  void _updatedGroupPic(String newGroupPic) {
    setState(() {
      widget.chatPic = newGroupPic;
      widget.conversation.updateGroupPic(newGroupPic);
    });
  }
}
