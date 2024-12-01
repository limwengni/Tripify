import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class ConversationTile extends StatefulWidget {
  final String currentUserId;
  final ConversationModel conversation;
  final void Function(String conversationPic) onTap;

  const ConversationTile({
    super.key,
    required this.currentUserId,
    required this.conversation,
    required this.onTap,
  });

  @override
  _ConversationTileState createState() => _ConversationTileState();
}

class _ConversationTileState extends State<ConversationTile> {
  String _conversationNameFuture = "";
  String _conversationPicFuture =
      "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-3.jpg";

  int? _unreadMessage;

  @override
  void initState() {
    super.initState();
    _fetchUserData(widget.currentUserId);
    _fetchConversationData(widget.conversation, widget.currentUserId);
  }

  void _fetchConversationData(
      ConversationModel conversation, String currentUserId) async {
    if (widget.conversation.latestMessage != null) {
      if (widget.conversation.unreadMessage != null &&
          widget.conversation.unreadMessage!.containsKey(currentUserId)) {
        _unreadMessage = widget.conversation.unreadMessage![currentUserId];
      }
    }
  }

  void _fetchUserData(String currentUserId) async {
    FirestoreService firestoreService = FirestoreService();

    String profilePic =
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-3.jpg';
    String username = 'Unknown User'; // Default value

    if (widget.conversation.isGroup == false) {
      for (var participant in widget.conversation.participants) {
        if (participant != currentUserId) {
          Map<String, dynamic>? userData =
              await firestoreService.getDataById('User', participant);

          // If the userData is available, assign new values
          profilePic = userData?['profile_picture'] ?? profilePic;
          username = userData?['username'] ?? username;
        }
      }

      if (mounted) {
        setState(() {
          _conversationPicFuture = profilePic;
          _conversationNameFuture = username;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _conversationPicFuture =
              widget.conversation.conversationPic ?? profilePic;
          _conversationNameFuture = widget.conversation.groupName ?? username;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap(_conversationPicFuture),
      child: Card(
        child: SizedBox(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: _conversationPicFuture != ''
                        ? Image.network(
                            _conversationPicFuture,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: Colors.grey, // Fallback color or placeholder
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _conversationNameFuture, // This appears to be a future, might need to await the value
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (widget.conversation.latestMessageType == 'text')
                      Text(widget.conversation.latestMessage ?? "")
                    else if (widget.conversation.latestMessageType == 'poll')
                      const Row(
                        children: [
                          Icon(
                            Icons.poll, // Choose an appropriate icon here
                            color:
                                Colors.blue, // Optional: Set color of the icon
                          ),
                          SizedBox(
                              width:
                                  8), // Optional: Space between the icon and the text
                          Text('Poll'),
                        ],
                      )
                    else if (widget.conversation.latestMessageType == 'pic')
                      const Row(
                        children: [
                          Icon(
                            Icons.image, // Choose an appropriate icon here
                            color:
                                Colors.blue, // Optional: Set color of the icon
                          ),
                          SizedBox(
                              width:
                                  8), // Optional: Space between the icon and the text
                          Text('Pic'),
                        ],
                      )
                    else if (widget.conversation.latestMessageType == 'video')
                      const Row(
                        children: [
                          Icon(
                            Icons
                                .video_camera_back_rounded, // Choose an appropriate icon here
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text('Video'),
                        ],
                      )
                    else if (widget.conversation.latestMessageType == 'file')
                      const Row(
                        children: [
                          Icon(
                            Icons.file_copy_rounded,
                            color: Colors.blue,
                          ),
                          SizedBox(width: 8),
                          Text('File'),
                        ],
                      )
                    else
                      Text(''),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    if (widget.conversation
                            .unreadMessage![widget.currentUserId] !=
                        0) ...[
                      Row(
                        children: [
                          if (widget.conversation.latestMessageSendDateTime !=
                              null)
                            Text(DateFormat('hh:mm a').format(widget
                                .conversation.latestMessageSendDateTime!)),
                        ],
                      ),
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          widget
                              .conversation.unreadMessage![widget.currentUserId]
                              .toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ] else
                      Row(
                        children: [
                          if (widget.conversation.latestMessageSendDateTime !=
                              null)
                            Text(DateFormat('hh:mm a').format(widget
                                .conversation.latestMessageSendDateTime!)),
                        ],
                      ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
