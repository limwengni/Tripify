import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/message_model.dart';
import 'package:tripify/models/poll_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/pdf_viewer_page.dart';
import 'package:tripify/widgets/video_preview.dart';

class ChatBubble extends StatefulWidget {
  final String message;
  final bool isCurrentUser;
  final String currentUser;
  final DateTime createdAt;
  final String contentType;
  final String? fileName;
  final String senderId;
  final bool isGroup;
  final ConversationModel conversation;
  final MessageModel messageModel;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.createdAt,
    required this.contentType,
    this.fileName,
    required this.senderId,
    required this.isGroup,
    required this.conversation,
    required this.currentUser,
    required this.messageModel,
  });

  @override
  _ChatBubbleState createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  PollModel? poll;
  int? selectedKey; // To track the selected container key
  FirestoreService firestoreService = FirestoreService();
  bool isPoll = false;
  int? pollAns;
  bool _isLoading = true;
  FirestoreService _firestoreService = FirestoreService();
  bool isDeleted = false;

  @override
  void initState() {
    super.initState();
    if (widget.contentType == 'poll') {
      fetchPollData();
    }
  }

  Future<void> fetchPollData() async {
    Map<String, dynamic>? data =
        await firestoreService.getSubCollectionDataById(
            collection: 'Conversations',
            subCollection: 'Poll',
            docId: widget.conversation.id,
            subDocId: widget.message);

    // Parse the data into your model
    if (data != null) {
      if (mounted) {
        setState(() {
          poll = PollModel.fromMap(data);
          if (data['answers'] is Map) {
            Map<String, dynamic> answers = data['answers'];
            for (var answer in answers.entries) {
              // answer.key is the key, and answer.value is the value
              if (widget.currentUser == answer.key) {
                isPoll = true;
                pollAns = answer.value;
              }
            }
          }
        });
      }
    }
  }

  void handleMenuAction(String action) {
    switch (action) {
      case 'Delete':
        _firestoreService.updateSubCollectionField(
            collection: 'Conversations',
            documentId: widget.conversation.id,
            subCollection: 'Messages',
            subDocumentId: widget.messageModel.id,
            field: 'is_deleted',
            value: !widget.messageModel.isDeleted);
        setState(() {});
        break;
      case 'Pin':
        _firestoreService.updateField('Conversations', widget.conversation.id,
            'message_pinned_id', widget.messageModel.content);
        setState(() {});
        break;

      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final String formattedTime = DateFormat('hh:mm a').format(widget.createdAt);
    FirestoreService firestoreService = FirestoreService();
    int optionsCount = -1;

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
        GestureDetector(
          onLongPress: () {
            // Show the options menu on long press
            if (widget.messageModel.isDeleted != true &&
                widget.messageModel.senderId == widget.currentUser) {
              showMenu(
                context: context,
                position: RelativeRect.fromLTRB(100, 100, 0, 0),
                items: [
                  const PopupMenuItem<String>(
                    value: 'Delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, color: Colors.red),
                        SizedBox(width: 10),
                        Text('Delete'),
                      ],
                    ),
                  ),
                  if (widget.conversation.isGroup)
                    if (widget.conversation.host == widget.currentUser &&
                        widget.contentType == 'text')
                      const PopupMenuItem<String>(
                        value: 'Pin',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Pin'),
                          ],
                        ),
                      ),
                  if (!widget.conversation.isGroup)
                    if (widget.contentType == 'text')
                      const PopupMenuItem<String>(
                        value: 'Pin',
                        child: Row(
                          children: [
                            Icon(Icons.edit, color: Colors.blue),
                            SizedBox(width: 10),
                            Text('Pin'),
                          ],
                        ),
                      ),
                ],
                elevation: 8.0,
              ).then((value) {
                if (value != null) {
                  handleMenuAction(value);
                }
              });
            }
          },
          child: Container(
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
                    if (widget.messageModel
                        .isDeleted) // Check if the message is deleted
                      Container(
                        // padding: EdgeInsets.all(8.0),
                        child: const Text(
                          'This message has been deleted.', // The deleted message text
                          style: TextStyle(
                              color: Colors.white, fontStyle: FontStyle.italic),
                        ),
                      )
                    else if (widget.contentType == "text")
                      ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width *
                              0.75, // Limit bubble width
                        ),
                        child: Text(
                          widget.message,
                          style: const TextStyle(color: Colors.white),
                          softWrap:
                              true, // Allows the text to wrap to the next line
                          overflow: TextOverflow
                              .visible, // Ensures text is visible in multiline
                        ),
                      )
                    else if (widget.contentType == "pic")
                      Stack(
                        children: [
                          // Loading circle (visible when loading)
                          if (_isLoading)
                            const Center(
                              child: SizedBox(
                                width: 200,
                                height: 200,
                                child: CircularProgressIndicator(
                                  color: Colors
                                      .blue, // Customize the color of the loading circle
                                  strokeWidth: 3.0,
                                ),
                              ),
                            ),
                          // The actual image
                          Image.network(
                            widget.message,
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) {
                                // Loading finished
                                _isLoading = false;
                                return child;
                              }
                              return const SizedBox(); // Return empty space while loading
                            },
                            errorBuilder: (context, error, stackTrace) {
                              // Display an error placeholder if the image fails to load
                              _isLoading = false;
                              return Container(
                                width: 200,
                                height: 200,
                                color: Colors.grey,
                                child:
                                    const Icon(Icons.error, color: Colors.red),
                              );
                            },
                          ),
                        ],
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
                      )
                    else if (widget.contentType == "poll")
                      // if(!isPoll)
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(239, 255, 255, 255),
                              borderRadius: BorderRadius.circular(15.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: poll == null
                                ? const Padding(
                                    padding: EdgeInsets.all(10.0),
                                    child:
                                        CircularProgressIndicator(), // Placeholder while data loads
                                  )
                                : Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          poll!.question,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        if (!isPoll)
                                          ...poll!.options.map((option) {
                                            final int optionKey = optionsCount +
                                                1; // Unique key for each option
                                            optionsCount++;
                                            return Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 5),
                                              child: Row(
                                                children: [
                                                  Container(
                                                    key: ValueKey(
                                                        optionKey), // Unique key for each container
                                                    width: 20,
                                                    height: 20,
                                                    decoration: BoxDecoration(
                                                      color: selectedKey ==
                                                              optionKey // Compare the current key to selectedKey
                                                          ? Colors
                                                              .green // Highlight color for the selected option
                                                          : Colors
                                                              .white, // Default color
                                                      shape: BoxShape.circle,
                                                      border: Border.all(
                                                        color: Colors.black,
                                                        width: 1,
                                                      ),
                                                    ),
                                                    child: selectedKey ==
                                                            optionKey
                                                        ? const Center(
                                                            child: Icon(
                                                              Icons.check,
                                                              color:
                                                                  Colors.white,
                                                              size: 16,
                                                            ),
                                                          )
                                                        : null,
                                                  ),
                                                  const SizedBox(width: 10),
                                                  Material(
                                                    elevation: 5,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Button shape
                                                    child: TextButton(
                                                      onPressed: () async {
                                                        Map<String, int>?
                                                            answerMap =
                                                            poll!.answers;

                                                        answerMap?.addEntries([
                                                          MapEntry(
                                                              widget
                                                                  .currentUser,
                                                              optionKey),
                                                        ]);

                                                        await firestoreService
                                                            .updateSubCollectionField(
                                                                collection:
                                                                    'Conversations',
                                                                documentId: widget
                                                                    .conversation
                                                                    .id,
                                                                subCollection:
                                                                    'Poll',
                                                                subDocumentId:
                                                                    widget
                                                                        .message,
                                                                field:
                                                                    'answers',
                                                                value:
                                                                    answerMap);
                                                        setState(() {
                                                          pollAns = optionKey;
                                                          selectedKey =
                                                              optionKey;
                                                          isPoll = true;
                                                        });
                                                      },
                                                      style:
                                                          TextButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor: Colors
                                                            .black, // Text color
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16.0,
                                                          vertical: 10.0,
                                                        ),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                      ),
                                                      child: Text(option),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          })
                                        else
                                          Table(
                                            columnWidths: const {
                                              0: FixedColumnWidth(30),
                                              1: FixedColumnWidth(100),
                                              2: FixedColumnWidth(60),
                                            },
                                            defaultVerticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            children: [
                                              ...poll!.options.map((option) {
                                                Map<int, int> answerMap =
                                                    calculatePollAnswer();
                                                Map<int, double>
                                                    answerMapPercentage =
                                                    calculatePollAnswerWithPercentage();

                                                final int optionKey =
                                                    optionsCount + 1;
                                                optionsCount++;

                                                return TableRow(
                                                  children: [
                                                    GestureDetector(
                                                      onTap: () {
                                                        setState(() {
                                                          selectedKey =
                                                              optionKey; // Update the selectedKey when the user taps
                                                        });
                                                      },
                                                      child: Container(
                                                        key: ValueKey(
                                                            optionKey), // Unique key for each container
                                                        width: 20,
                                                        height: 20,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: pollAns ==
                                                                  optionKey
                                                              ? Colors
                                                                  .green // Highlight color for the selected option
                                                              : Colors
                                                                  .white, // Default color
                                                          shape:
                                                              BoxShape.circle,
                                                          border: Border.all(
                                                            color: Colors
                                                                .black, // Border color
                                                            width:
                                                                1, // Border width
                                                          ),
                                                        ),
                                                        child: pollAns ==
                                                                optionKey
                                                            ? const Center(
                                                                child: Icon(
                                                                  Icons.check,
                                                                  color: Colors
                                                                      .white,
                                                                  size: 16,
                                                                ),
                                                              )
                                                            : null,
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          5.0, 0, 5, 0),
                                                      child: Material(
                                                        elevation: 5,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        child: TextButton(
                                                          onPressed: null,
                                                          style: TextButton
                                                              .styleFrom(
                                                            backgroundColor:
                                                                Colors.white,
                                                            foregroundColor: Colors
                                                                .black, // Text color
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 16.0,
                                                              vertical: 10.0,
                                                            ),
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          10),
                                                            ),
                                                          ),
                                                          child: Text(option),
                                                        ),
                                                      ),
                                                    ),
                                                    if (answerMapPercentage
                                                        .containsKey(optionKey))
                                                      Text(
                                                          '${answerMapPercentage[optionKey]!.toStringAsFixed(2)}%')
                                                    else
                                                      Text('0%'),
                                                  ],
                                                );
                                              }).toList(),
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                          ),
                        ],
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

  Map<int, int> calculatePollAnswer() {
    Map<int, int> answerList = {}; // New map to hold the count of occurrences

    // Iterate through the original poll answers
    for (var answer in poll!.answers!.entries) {
      // The value of the current entry in the original map is the new key
      // If the key exists in the new map, increment the count, otherwise set it to 1
      if (answerList.containsKey(answer.value)) {
        answerList[answer.value] = answerList[answer.value]! + 1;
      } else {
        answerList[answer.value] = 1;
      }
    }

    return answerList;
  }

  Map<int, double> calculatePollAnswerWithPercentage() {
    Map<int, double> answerList =
        {}; // New map to hold the percentage of occurrences

    int totalVotes = poll!.answers!.length; // Get the total number of entries

    // Iterate through the original poll answers
    for (var answer in poll!.answers!.entries) {
      // The value of the current entry in the original map is the new key
      if (answerList.containsKey(answer.value)) {
        answerList[answer.value] = answerList[answer.value]! + 1;
      } else {
        answerList[answer.value] = 1;
      }
    }

    // Convert counts to percentages
    answerList.updateAll((key, value) {
      return (value / totalVotes) * 100; // Convert to percentage
    });

    return answerList;
  }
}
