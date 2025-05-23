import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/message_model.dart';
import 'package:tripify/view_models/conversation_view_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/widgets/chat_bubble.dart';
import 'package:tripify/widgets/pin_message.dart';

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final String chatPic;
  final String? predefineString;

  ChatPage(
      {Key? key,
      required this.conversation,
      required this.currentUserId,
      required this.chatPic,
      this.predefineString})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // FirestoreService firestoreService = FirestoreService();
  FirebaseStorageService _firebaseStorageService = FirebaseStorageService();
  FirestoreService _firestoreService = FirestoreService();
  TextEditingController _messageController = TextEditingController();
  final ConversationViewModel _conversationViewModel = ConversationViewModel();
  String appBarTitle = "Loading...";
  bool extraAction = false;
  final ValueNotifier<bool> _extraActionNotifier = ValueNotifier<bool>(false);
  final ImagePicker picker = ImagePicker();
  XFile? _imageSelected = null;
  String? fileName;
  late FocusNode _textFieldFocusNode; // FocusNode for the TextField

  //
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _setAppBarTitle();
    if (widget.predefineString != null) {
      _messageController = TextEditingController(text: widget.predefineString);
      _textFieldFocusNode = FocusNode();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textFieldFocusNode.requestFocus(); // Open the keyboard
      });
    }
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

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _conversationViewModel.sendMessage(
        senderID: widget.currentUserId,
        content: _messageController.text,
        contentType: ContentType.text,
        conversation: widget.conversation,
      );

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
    _textFieldFocusNode.dispose(); // Dispose of the FocusNode

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
                  child: Image.network(
                widget.chatPic,
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              )),
              const SizedBox(
                width: 10,
              ),
              Text(appBarTitle)
            ],
          ),
        ),
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
        // Error handling
        if (snapshot.hasError) {
          return const Text('Error fetching pinned message');
        }

        // Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text('Loading...');
        }

        // Check if the document exists and has the pinned message
        var document = snapshot.data;
        if (document != null && document.exists) {
          // Assuming you store the pinned message in a field 'message_pinned_id'
          String? pinnedMessage = document['message_pinned_id'];

          // If there's a pinned message, return the PinMessage widget
          if (pinnedMessage != null && pinnedMessage.isNotEmpty) {
            return PinMessage(message: pinnedMessage);
          }
        }

        // Return an empty container if no pinned message
        return SizedBox
            .shrink(); // Or you can return Container() for the same effect
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
      // ),
    );
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
                  focusNode: widget.predefineString != null
                      ? _textFieldFocusNode
                      : null,
                  maxLines: 3,
                  minLines: 1,
                  keyboardType: TextInputType.multiline,
                  textInputAction:
                      TextInputAction.newline, // Allows newline input
                  scrollPadding:
                      EdgeInsets.all(10), // Adds scrollable padding for comfort
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
                  color:         const Color.fromARGB(255, 159, 118,249),
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
}
