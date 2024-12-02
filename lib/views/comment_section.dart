import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/comment_model.dart';
import 'package:tripify/view_models/user_provider.dart';
import 'package:tripify/view_models/post_provider.dart';
import 'package:tripify/views/user_profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CommentSection extends StatefulWidget {
  final ScrollController scrollController;
  final String postId;

  CommentSection({required this.scrollController, required this.postId});

  @override
  _CommentSectionState createState() => _CommentSectionState();
}

class _CommentSectionState extends State<CommentSection> {
  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  // final int _maxCommentLength = 200;

  List<PostComment> comments = [];
  bool isLoading = false;
  Map<String, String?> userProfileCache = {};

  @override
  void initState() {
    super.initState();

    // _commentController.addListener(() {
    //   if (_commentController.text.length > _maxCommentLength) {
    //     _commentController.text =
    //         _commentController.text.substring(0, _maxCommentLength);
    //     _commentController.selection = TextSelection.fromPosition(
    //         TextPosition(offset: _commentController.text.length));
    //   }
    //   setState(() {});
    // });

    _loadComments();
  }

  Future<void> _fetchUserDetails(String userId) async {
    // Access userProvider here using context
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    // Check if the details are already cached
    if (!userProfileCache.containsKey(userId)) {
      String? username = await userProvider.fetchUsername(userId);
      String? profilePic = await userProvider.fetchUserProfilePic(userId);

      setState(() {
        userProfileCache[userId] = username;
        userProfileCache['${userId}_pic'] = profilePic;
      });
    }
  }

  Future<void> _loadComments() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<PostComment> fetchedComments =
          await PostProvider().fetchCommentsForPost(widget.postId);

      setState(() {
        comments = fetchedComments;
      });

      for (var comment in fetchedComments) {
        await _fetchUserDetails(comment.userId);
      }

      print("Fetched comments: $fetchedComments");
    } catch (e) {
      print("Error fetching comments: $e");
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return '${weeks}w'; // "1w"
    } else if (difference.inDays >= 1) {
      return '${difference.inDays}d'; // "1d"
    } else if (difference.inHours >= 1) {
      return '${difference.inHours}h'; // "1h"
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes}m'; // "1m"
    } else {
      return '${difference.inSeconds}s'; // "1s"
    }
  }

  Future<void> submitComment(String postId, String text) async {
    String userId = FirebaseAuth.instance.currentUser!.uid;

    PostComment newComment = PostComment(
      id: '',
      postId: postId,
      userId: userId,
      text: text,
      createdAt: DateTime.now(),
    );

    try {
      // Upload comment to the database
      await PostProvider().uploadComment(newComment, context);

      await _loadComments();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Comment uploaded successfully!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        ),
      );
    } catch (e) {
      print("Error uploading comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to upload comment. Please try again.',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _deleteComment(String commentId, String postId, String userId,
      BuildContext context) async {
    try {
      await PostProvider().deleteComment(commentId, postId, userId, context);

      // Remove the deleted comment from the list
      setState(() {
        comments.removeWhere((comment) => comment.id == commentId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Comment deleted successfully',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Color.fromARGB(255, 159, 118, 249),
        ),
      );
    } catch (e) {
      print("Error deleting comment: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete comment. Please try again.',
              style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        // Unfocus when tapping anywhere outside the form
        FocusScope.of(context).unfocus();
      },
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Colors.grey[900]
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.0),
            topRight: Radius.circular(16.0),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 2, bottom: 8),
                    height: 6,
                    width: 70,
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  Text(
                    "Comments",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.0),

            // Divider
            Container(
              margin: EdgeInsets.only(
                  top: 4, bottom: 8), // Optional margin for spacing
              height: 2, // Height of the divider
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[300], // Color of the divider
            ),

            SizedBox(height: 8.0),

            // Comment input section
            Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Form(
                  key: _formKey,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 60,
                          child: TextFormField(
                            cursorColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                            controller: _commentController,
                            keyboardType: TextInputType.multiline,
                            focusNode: _commentFocusNode,
                            decoration: InputDecoration(
                              hintText: "Write a comment...",
                              border: OutlineInputBorder(),
                              counterText: "",
                              suffixStyle: TextStyle(
                                color: Colors.grey,
                              ),
                              suffixIcon:
                                  ValueListenableBuilder<TextEditingValue>(
                                valueListenable: _commentController,
                                builder: (context, value, child) {
                                  return value.text.isNotEmpty
                                      ? IconButton(
                                          icon: Icon(Icons.send),
                                          onPressed: () async {
                                            // Check if the form is valid before submitting
                                            if (_formKey.currentState
                                                    ?.validate() ??
                                                false) {
                                              String commentText =
                                                  _commentController.text;

                                              await submitComment(
                                                  widget.postId, commentText);

                                              _commentController.clear();

                                              FocusScope.of(context).unfocus();
                                            }
                                          },
                                        )
                                      : SizedBox.shrink();
                                },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a comment';
                              }
                              if (value.length < 3) {
                                return 'Comment must be at least 3 characters long';
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
            // Display list of comments
            Expanded(
              child: isLoading
                  ? Center(
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: ListView.builder(
                          itemCount: 10,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: CircleAvatar(
                                radius: 20,
                                backgroundColor: Colors.grey.shade300,
                              ),
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  // Shimmer effect for the comment text
                                  Container(
                                    height: 14.0,
                                    width: 100.0,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: 8),
                                  // Shimmer effect for the comment text
                                  Container(
                                    height: 14.0,
                                    color: Colors.grey.shade300,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    )
                  : comments.isEmpty
                      ? Center(
                          child: Text(
                            'No comments found',
                            style: TextStyle(color: Colors.grey, fontSize: 16),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.only(top: 10.0),
                          child: ListView.builder(
                            controller: widget.scrollController,
                            itemCount: comments.length,
                            itemBuilder: (context, index) {
                              final comment = comments[index];
                              String? username =
                                  userProfileCache[comment.userId];
                              String? profilePic =
                                  userProfileCache['${comment.userId}_pic'];
                              String currentUserId =
                                  FirebaseAuth.instance.currentUser!.uid;
                              String relativeTime =
                                  formatTimeAgo(comment.createdAt);

                                  print("current user id: $currentUserId");
                                  print("comment user id: ${comment.userId}");

                              return ListTile(
                                leading: profilePic != null
                                    ? GestureDetector(
                                        onTap: () {
                                          // Navigate to user profile page
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  UserProfilePage(
                                                      userId: comment.userId),
                                            ),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundImage:
                                              NetworkImage(profilePic),
                                        ),
                                      )
                                    : Icon(Icons.account_circle),
                                title: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserProfilePage(
                                                    userId: comment.userId),
                                          ),
                                        );
                                      },
                                      child: Text(username ?? 'Unknown'),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      relativeTime, // Show relative time (e.g., 1m, 1h, 1d)
                                      style: TextStyle(
                                          color: Colors.grey[500],
                                          fontSize: 14),
                                    ),
                                  ],
                                ),
                                subtitle: Text(comment.text),
                                trailing: currentUserId == comment.userId
                                    ? IconButton(
                                        icon: Icon(Icons.delete),
                                        onPressed: () async {
                                          await _deleteComment(
                                              comment.id,
                                              widget.postId,
                                              FirebaseAuth
                                                  .instance.currentUser!.uid,
                                              context);
                                        },
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
            )
          ],
        ),
      ),
    );
  }
}
