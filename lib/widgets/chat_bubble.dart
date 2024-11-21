import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tripify/views/pdf_viewer_page.dart';
import 'package:tripify/widgets/video_preview.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final DateTime createdAt;
  final String contentType;
  final String? fileName;

  const ChatBubble(
      {super.key,
      required this.message,
      required this.isCurrentUser,
      required this.createdAt,
      required this.contentType,
      this.fileName});

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
              Image.network(
                message,
              )
            else if (contentType == "video")
              VideoPreview(
                videoPath: message,
                isCurrentUser: isCurrentUser,
              )
            else if (contentType == "file")
              InkWell(
                onTap: () {
                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PdfViewerPage(pdfUrl: message),
  ),
);
                 print(message);
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
                        Icon(
                          Icons.file_copy_outlined,
                          color: Colors.white,
                        ),
                        const SizedBox(
                            width: 8), // Add spacing between icon and text
                        ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth:
                                200, // Set your desired maximum width here
                          ),
                          child: Text(
                            fileName!,
                            style: const TextStyle(color: Colors.white),
                            overflow: TextOverflow
                                .ellipsis, // Show "..." if the text overflows
                            maxLines: 1, // Ensure it's a single-line text
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ));
  }
}
