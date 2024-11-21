import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/widgets/video_preview.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime createdAt;
  final String contentType;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.createdAt,
      required this.contentType});

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat('hh:mm a').format(createdAt);

    return Container(
      decoration: BoxDecoration(
          color: isCurrentUser ? Colors.green : Colors.grey.shade500,
          borderRadius: BorderRadius.circular(15.0)), // BoxDecoration
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          if (contentType == "text")
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            )
          else if (contentType == "pic")
            Image.network(message,)
          else if (contentType == "video")
            VideoPreview(
              videoPath: message,
              isCurrentUser: isCurrentUser,
            ),
            const SizedBox(height: 5),
          Text(
            formattedTime,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
