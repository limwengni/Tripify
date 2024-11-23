import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';

class GroupChatUserCard extends StatefulWidget {
  ConversationModel conversation;
  final UserModel user;
  final bool addToGroup;
  final Function(ConversationModel)
      onConversationUpdated; // Callback for updating conversation

  GroupChatUserCard({
    super.key,
    required this.user,
    required this.addToGroup,
    required this.conversation,
    required this.onConversationUpdated,
  });

  @override
  _GroupChatUserCardState createState() => _GroupChatUserCardState();
}

class _GroupChatUserCardState extends State<GroupChatUserCard> {
  FirestoreService _firestoreService = FirestoreService();
  bool added = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey.shade200,
                child: ClipOval(
                  child: Image.network(
                    widget.user.profilePic,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(widget.user.username),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  if (widget.addToGroup) {
                    widget.conversation.addParticipant(widget.user.uid);

                    setState(() {
                      added = true;
                    });
                    widget.onConversationUpdated(widget.conversation);
                  } else {
                    widget.conversation.removeParticipant(widget.user.uid);
                    _firestoreService.updateData("Conversations", widget.conversation.id, widget.conversation.toMap());
                                        widget.onConversationUpdated(widget.conversation);

                  }
                },
                icon: added
                    ? Icon(Icons
                        .check) // Use a different icon to indicate it has been added
                    : (widget.addToGroup
                        ? Icon(Icons.add)
                        : Icon(Icons.remove)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
