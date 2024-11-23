import 'package:flutter/material.dart';
import 'package:tripify/models/conversation_model.dart';

class GroupChatEditPage extends StatefulWidget {
  final ConversationModel conversation;

  const GroupChatEditPage ({Key? key, required this.conversation})
      : super(key: key);

  @override
  _GroupChatEditPageState createState() =>
      _GroupChatEditPageState();
}

class _GroupChatEditPageState extends State<GroupChatEditPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.conversation.groupName!),
          
        ),
        body: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              ClipOval(
                  child: Image.network(
                widget.conversation.conversationPic!,
                width: 220,
                height: 220,
                fit: BoxFit.cover,
              )),
              Text(widget.conversation.groupName!),
            ],
          ),
        ));
  }
}
