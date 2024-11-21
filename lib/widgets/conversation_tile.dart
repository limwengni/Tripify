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
  String _conversationPicFuture = "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-3.jpg";
  String? _latestMessageSendDateTime;
  String? _latestMessage ;
  int? _unreadMessage ;

  @override
  void initState() {
    super.initState();
    _fetchUserData(widget.currentUserId);
    _fetchConversationData(widget.conversation, widget.currentUserId);
  }

  void _fetchConversationData(
      ConversationModel conversation, String currentUserId) async {
    if (widget.conversation.latestMessage != null) {
      _latestMessageSendDateTime = DateFormat('hh:mm a')
          .format(widget.conversation.latestMessageSendDateTime!);
      _latestMessage = widget.conversation.latestMessage;
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
                    child: Image.network(
                      _conversationPicFuture,
                      width: 60,
                      height: 60,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _conversationNameFuture,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(widget.conversation.latestMessage ?? ""),
                  ],
                ),
                const Spacer(),
                Column(
                  children: [
                    if (_unreadMessage != 0) ...[
                      Row(
                        children: [
                          Text(_latestMessageSendDateTime ?? ""),
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
                          _unreadMessage?.toString() ?? '0',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]
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
