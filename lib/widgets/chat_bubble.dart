import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/pdf_viewer_page.dart';
import 'package:tripify/widgets/video_preview.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime createdAt;
  final String contentType;
  final String? fileName;
  final String senderId;
  final bool isGroup;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.createdAt,
    required this.contentType,
    this.fileName,
    required this.senderId,
    required this.isGroup,
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat('hh:mm a').format(widget.createdAt);

    return Row(
      mainAxisAlignment: widget.isCurrentUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        if (widget.isGroup)
          if (!widget.isCurrentUser)
            FutureBuilder<Map<String, String>>(
              future: _fetchUserData(widget.senderId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Show a loader while fetching
                } else if (snapshot.hasError) {
                  return const Icon(Icons.error); // Handle error case
                } else {
                  final userData = snapshot.data!;
                  return ClipOval(
                    child: Image.network(
                      userData['profilePicture']!,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                    ),
                  );
                }
              },
            ),
        const SizedBox(
          width: 5,
        ),
        Container(
          decoration: BoxDecoration(
            color: widget.isCurrentUser ? Colors.green : Colors.grey.shade500,
            borderRadius: BorderRadius.circular(15.0),
          ),
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: widget.isCurrentUser
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  if (!widget.isCurrentUser)
                    FutureBuilder<Map<String, String>>(
                      future: _fetchUserData(widget.senderId),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const CircularProgressIndicator(); // Show a loader while fetching
                        } else if (snapshot.hasError) {
                          return const Icon(Icons.error); // Handle error case
                        } else {
                          final userData = snapshot.data!;
                          return Text(
                            userData['username']!,
                            style: TextStyle(color: Colors.white),
                          );
                        }
                      },
                    ),
                  if (widget.contentType == "text")
                    Text(
                      widget.message,
                      style: const TextStyle(color: Colors.white),
                    )
                  else if (widget.contentType == "pic")
                    Image.network(
                      widget.message,
                      width: 200,
                      height: 200,
                      fit: BoxFit.cover,
                    )
                  else if (widget.contentType == "video")
                    VideoPreview(
                      videoPath: widget.message,
                      isCurrentUser: widget.isCurrentUser,
                    )
                  else if (widget.contentType == "file")
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                PdfViewerPage(pdfUrl: widget.message),
                          ),
                        );
                        print(widget.message);
                      },
                      borderRadius: BorderRadius.circular(
                          8), // Match the Container's border radius
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.file_copy_outlined,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth:
                                      200, // Set your desired maximum width here
                                ),
                                child: Text(
                                  widget.fileName ?? 'Unknown file',
                                  style: const TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Text(
                    formattedTime,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<Map<String, String>> _fetchUserData(String senderId) async {
    FirestoreService firestoreService = FirestoreService();

    String profilePic =
        'https://flutter.github.io/assets-for-api-docs/assets/widgets/owl-3.jpg';
    String username = 'Unknown User'; // Default value

    Map<String, dynamic>? userData =
        await firestoreService.getDataById('User', senderId);

    profilePic = userData?['profile_picture'] ?? profilePic;
    username = userData?['username'] ?? username;

    return {
      'profilePicture': profilePic,
      'username': username,
    };
  }
}
