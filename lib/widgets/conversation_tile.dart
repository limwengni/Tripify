import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/models/user_model.dart';
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
  UserModel? user;
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
    Map<String, dynamic>? userData;
    if (widget.conversation.isGroup == false) {
      for (var participant in widget.conversation.participants) {
        if (participant != currentUserId) {
          userData = await firestoreService.getDataById('User', participant);

          // If the userData is available, assign new values
          profilePic = userData?['profile_picture'] ?? profilePic;
          username = userData?['username'] ?? username;
          if (userData != null) {
            user = UserModel.fromMap(userData, participant);
          }
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
                // Left: Avatar and Info
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
                            child: const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _conversationNameFuture,
                              style: Theme.of(context).textTheme.titleMedium,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      if (widget.conversation.latestMessageType == 'text')
                        Row(
                          children: [
                            if (user?.role == 'Accommodation Rental Company')
                              Container(
                                  width: 24, // Size of the icon
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 159, 118,
                                        249), // Purple background color
                                    shape: BoxShape.circle, // Make it circular
                                  ),
                                  alignment: Alignment
                                      .center, // Center the letter inside the circle
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // White text for contrast
                                      fontWeight: FontWeight
                                          .bold, // Bold text for visibility
                                      fontSize: 14, // Font size of the letter
                                    ),
                                  ))
                            else if (user?.role == 'Car Rental Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'C',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              )
                            else if (user?.role == 'Travel Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'T',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            Expanded(
                                child: Text(
                                    widget.conversation.latestMessage ?? "",
                                    overflow: TextOverflow.ellipsis))
                          ],
                        )
                      else if (widget.conversation.latestMessageType == 'poll')
                        Row(
                          children: [
                            if (user?.role == 'Accommodation Rental Company')
                              Container(
                                  width: 24, // Size of the icon
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 159, 118,
                                        249), // Purple background color
                                    shape: BoxShape.circle, // Make it circular
                                  ),
                                  alignment: Alignment
                                      .center, // Center the letter inside the circle
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // White text for contrast
                                      fontWeight: FontWeight
                                          .bold, // Bold text for visibility
                                      fontSize: 14, // Font size of the letter
                                    ),
                                  ))
                            else if (user?.role == 'Car Rental Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'C',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              )
                            else if (user?.role == 'Travel Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'T',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.poll,
                              color: 
                              Color.fromARGB(255, 159, 118, 249),
                            ),
                            SizedBox(width: 8),
                            Text('Poll'),
                          ],
                        )
                      else if (widget.conversation.latestMessageType == 'pic')
                        Row(
                          children: [
                            if (user?.role == 'Accommodation Rental Company')
                              Container(
                                  width: 24, // Size of the icon
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 159, 118,
                                        249), // Purple background color
                                    shape: BoxShape.circle, // Make it circular
                                  ),
                                  alignment: Alignment
                                      .center, // Center the letter inside the circle
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // White text for contrast
                                      fontWeight: FontWeight
                                          .bold, // Bold text for visibility
                                      fontSize: 14, // Font size of the letter
                                    ),
                                  ))
                            else if (user?.role == 'Car Rental Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'C',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              )
                            else if (user?.role == 'Travel Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'T',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.image,
                              color: Color.fromARGB(255, 159, 118, 249),
                            ),
                            SizedBox(width: 8),
                            Text('Pic'),
                          ],
                        )
                      else if (widget.conversation.latestMessageType == 'video')
                        Row(
                          children: [
                            if (user?.role == 'Accommodation Rental Company')
                              Container(
                                  width: 24, // Size of the icon
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 159, 118,
                                        249), // Purple background color
                                    shape: BoxShape.circle, // Make it circular
                                  ),
                                  alignment: Alignment
                                      .center, // Center the letter inside the circle
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // White text for contrast
                                      fontWeight: FontWeight
                                          .bold, // Bold text for visibility
                                      fontSize: 14, // Font size of the letter
                                    ),
                                  ))
                            else if (user?.role == 'Car Rental Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'C',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              )
                            else if (user?.role == 'Travel Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'T',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.video_camera_back_rounded,
                              color: Color.fromARGB(255, 159, 118, 249),
                            ),
                            SizedBox(width: 8),
                            Text('Video'),
                          ],
                        )
                      else if (widget.conversation.latestMessageType == 'file')
                        Row(
                          children: [
                            if (user?.role == 'Accommodation Rental Company')
                              Container(
                                  width: 24, // Size of the icon
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(255, 159, 118,
                                        249), // Purple background color
                                    shape: BoxShape.circle, // Make it circular
                                  ),
                                  alignment: Alignment
                                      .center, // Center the letter inside the circle
                                  child: const Text(
                                    'A',
                                    style: TextStyle(
                                      color: Colors
                                          .white, // White text for contrast
                                      fontWeight: FontWeight
                                          .bold, // Bold text for visibility
                                      fontSize: 14, // Font size of the letter
                                    ),
                                  ))
                            else if (user?.role == 'Car Rental Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'C',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              )
                            else if (user?.role == 'Travel Company')
                              Container(
                                width: 24, // Size of the icon
                                height: 24,
                                decoration: BoxDecoration(
                                  color: Color.fromARGB(255, 159, 118,
                                      249), // Purple background color
                                  shape: BoxShape.circle, // Make it circular
                                ),
                                alignment: Alignment
                                    .center, // Center the letter inside the circle
                                child: const Text(
                                  'T',
                                  style: TextStyle(
                                    color:
                                        Colors.white, // White text for contrast
                                    fontWeight: FontWeight
                                        .bold, // Bold text for visibility
                                    fontSize: 14, // Font size of the letter
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: 5,
                            ),
                            Icon(
                              Icons.file_copy_rounded,
                              color: Color.fromARGB(255, 159, 118, 249),

                            ),
                            SizedBox(width: 8),
                            Text('File'),
                          ],
                        )
                      else
                        const Text(''),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end, // Align to right
                  children: [
                    if (widget.conversation.latestMessageSendDateTime != null)
                      Text(
                        DateFormat('hh:mm a').format(
                          widget.conversation.latestMessageSendDateTime!,
                        ),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (widget.conversation
                            .unreadMessage![widget.currentUserId] !=
                        0)
                      Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 159, 118, 249),
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
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
