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

class ChatPage extends StatefulWidget {
  final ConversationModel conversation;
  final String currentUserId;
  final String chatPic;

  ChatPage(
      {Key? key,
      required this.conversation,
      required this.currentUserId,
      required this.chatPic})
      : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  // FirestoreService firestoreService = FirestoreService();
  FirebaseStorageService _firebaseStorageService = FirebaseStorageService();
  final TextEditingController _messageController = TextEditingController();
  final ConversationViewModel _conversationViewModel = ConversationViewModel();
  String appBarTitle = "Loading...";
  bool extraAction = false;
  final ValueNotifier<bool> _extraActionNotifier = ValueNotifier<bool>(false);

  final ImagePicker picker = ImagePicker();
  XFile? _imageSelected = null;
  String? fileName;

  @override
  void initState() {
    super.initState();
    _setAppBarTitle();
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
        conversationId: widget.conversation.id,
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
    _messageController.dispose();
    _extraActionNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: _buildMessageList(widget.conversation.id),
            ),
          ),
          _buildUserInput(widget.currentUserId, widget.conversation.id)
        ],
      ),
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

          return ListView(
            children: snapshot.data!.docs
                .map<Widget>((doc) => _buildMessageItem(doc, currentUserId))
                .toList(),
          );
        });
  }

  Widget _buildMessageItem(DocumentSnapshot doc, String currentUserId) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['sender_id'] == currentUserId;

    // var alignment =
    //     isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;
    return
        // Container(
        //     alignment: alignment,
        // child:
        Column(
      crossAxisAlignment:
          isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        ChatBubble(
          message: data['content'],
          isCurrentUser: isCurrentUser,
          createdAt: data['created_at'].toDate(),
          contentType: data['content_type'],
          fileName: data['file_name'],
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
                      _buildActionItem(
                          Icons.camera_alt_outlined, 'Camera', () async {}),
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
                                conversationId: conversationId,
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
                                    conversationId: conversationId);
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
                                  conversationId: conversationId,
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
}
