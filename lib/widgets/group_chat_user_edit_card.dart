import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
class GroupChatUserEditCard extends StatefulWidget {
  final UserModel user;
  final bool addToGroup;
  final ConversationModel conversation;
  final Function(ConversationModel) onConversationUpdated;
  final Function(UserModel) onUserAdded; // Callback when a user is added
  final Function(UserModel) onUserRemoved; // Callback when a user is removed

  GroupChatUserEditCard({
    super.key,
    required this.user,
    required this.addToGroup,
    required this.conversation,
    required this.onConversationUpdated,
    required this.onUserAdded,
    required this.onUserRemoved,
  });

  @override
  _GroupChatUserEditCardState createState() => _GroupChatUserEditCardState();
}

class _GroupChatUserEditCardState extends State<GroupChatUserEditCard> {
  bool added = false;

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
                  if (added) {
                    // Remove the user
                    widget.conversation.removeParticipant(widget.user.uid);
                    widget.onUserRemoved(widget.user); // Notify parent
                  } else {
                    // Add the user
                    widget.conversation.addParticipant(widget.user.uid);
                    widget.onUserAdded(widget.user); // Notify parent
                  }
                  widget.onConversationUpdated(widget.conversation);
                  setState(() {
                    added = !added;
                  });
                },
                icon: added
                    ? Icon(Icons.check)
                    : Icon(widget.addToGroup ? Icons.add : Icons.remove),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
