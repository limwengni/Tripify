import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/view_models/post_provider.dart';
import 'package:tripify/view_models/user_provider.dart';
import 'package:tripify/view_models/poll_provider.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/models/comment_model.dart';
import 'package:tripify/views/user_profile_page.dart';
import 'package:tripify/views/edit_post_page.dart';
import 'package:tripify/views/comment_section.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;
  final String id;

  // Constructor to accept the post object
  PostDetailPage({required this.post, required this.id});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage>
    with WidgetsBindingObserver {
  late String _id;
  late String _title;
  late String _description;
  late String _location;
  late int likeCount;
  late int commentCount;
  late int saveCount;
  late DateTime _createdAt;
  late String formattedDate;
  int _currentPage = 0;
  final Map<int, VideoPlayerController> _controllers = {};
  final Map<int, bool> _isMuted = {};
  bool isLiked = false;
  bool liked = false;
  bool isSaved = false;
  bool saved = false;
  bool voted = false;
  String? username;
  List<PostComment> comments = [];
  bool isLoading = false;
  late String? _pollQuestion;
  late List<String>? _pollOptions;
  String? _selectedOption;
  String? fetchedSelectedOption;
  Map<String, int> pollResults = {};

  final TextEditingController _commentController = TextEditingController();
  final FocusNode _commentFocusNode = FocusNode();
  final int _maxCommentLength = 200;
  final _formKey = GlobalKey<FormState>();

  PollProvider pollProvider = new PollProvider();

  @override
  void initState() {
    super.initState();

    // Initialize post details from widget.post
    _id = widget.id;
    _title = widget.post.title;
    _description = widget.post.description ?? '';
    _location = widget.post.location ?? '';
    likeCount = widget.post.likesCount;
    commentCount = widget.post.commentsCount;
    saveCount = widget.post.savedCount;
    _createdAt = widget.post.createdAt;
    _pollQuestion = widget.post.pollQuestion;
    _pollOptions = widget.post.pollOptions;

    _description = _description.replaceAll(r'\n', '\n');

    formattedDate = formatPostDate(_createdAt.toLocal());

    for (int i = 0; i < widget.post.media.length; i++) {
      print('Media $i: ${widget.post.media[i]}');
      print(isVideo(widget.post.media[i]));
    }

    for (int i = 0; i < widget.post.media.length; i++) {
      _isMuted[i] = false;
    }

    final user = FirebaseAuth.instance.currentUser;

    _checkIfLiked(_id, user!.uid);

    _checkIfSaved(_id, user!.uid);

    _checkIfUserVoted();

    WidgetsBinding.instance.addObserver(this);

    _fetchUsernameAndPfp();
  }

  Future<void> _checkIfUserVoted() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      fetchedSelectedOption =
          await pollProvider.getUserSelectedOption(widget.id, userId);
      final results = await pollProvider.getPollResults(widget.id);

      pollResults = results;
      if (fetchedSelectedOption != null) {
        voted = true;
      }
      setState(() {});
    }
  }

  Future<void> _refreshData() async {
    await _fetchUpdatedPostData(_id);
    setState(() {});
  }

  Future<void> _fetchUsernameAndPfp() async {
    // Access userProvider here using context
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (widget.post.userId == FirebaseAuth.instance.currentUser?.uid) {
      await userProvider.fetchUserDetails(widget.post.userId);
    } else {
      await userProvider.fetchOtherUserDetails(widget.post.userId);
    }
  }

  String formatPostDate(DateTime createdAt) {
    DateTime now = DateTime.now();

    print('NOW: $now');
    DateTime localCreatedAt = createdAt.toLocal();
    print('localCreatedAt: $localCreatedAt');

    Duration difference = now.difference(localCreatedAt);

    if (difference.inMinutes < 1) {
      return "Just Now";
    } else if (difference.inMinutes < 60) {
      return "${difference.inMinutes} Minute${difference.inMinutes > 1 ? 's' : ''} Ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} Hour${difference.inHours > 1 ? 's' : ''} Ago";
    } else if (difference.inDays == 1) {
      return "1 Day Ago";
    } else {
      return DateFormat('d MMMM yyyy')
          .format(localCreatedAt); // "4 August 2023"
    }
  }

  Future<void> _fetchUpdatedPostData(String postId) async {
    try {
      // Assuming your PostProvider has a method to fetch a post by ID
      var updatedPost = await PostProvider().fetchPostById(postId);

      // Update your local variables with the fetched data
      setState(() {
        _title = updatedPost.title;
        _description = updatedPost.description ?? '';
        _location = updatedPost.location ?? '';
        likeCount = updatedPost.likesCount;
        commentCount = updatedPost.commentsCount;
        saveCount = updatedPost.savedCount;
        _createdAt = updatedPost.createdAt;
        _pollQuestion = updatedPost.pollQuestion;
        _pollOptions = updatedPost.pollOptions;
        _description = _description.replaceAll(r'\n', '\n');
        formattedDate = formatPostDate(_createdAt.toLocal());
      });

      // Handle media and mute states
      for (int i = 0; i < updatedPost.media.length; i++) {
        _controllers[i]?.dispose();
        _controllers.remove(i);
        _isMuted[i] = false;
      }

      for (int i = 0; i < updatedPost.media.length; i++) {
        print('Updated Media $i: ${updatedPost.media[i]}');
      }
    } catch (e) {
      print('Error fetching updated post: $e');
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    // Dispose of controllers when done
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (username == null) {
      _fetchUsernameAndPfp();
    }

    // Resume video when returning to the page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      bool containsKey = _controllers.containsKey(_currentPage);
      bool isInitialized =
          containsKey && _controllers[_currentPage]!.value.isInitialized;

      // Print the status of containsKey and isInitialized
      print('Contains key: $containsKey');
      print('Is initialized: $isInitialized');

      if (!containsKey || !isInitialized) {
        _refreshData();
      }

      if (containsKey && isInitialized) {
        _controllers[_currentPage]!.play();
        _controllers[_currentPage]!.setVolume(1.0);
      }
    });
  }

  VideoPlayerController getVideoController(String videoUrl) {
    return VideoPlayerController.file(File(videoUrl))
      ..initialize().then((_) {
        setState(() {});
      }).catchError((e) {
        print('Video initialization failed: $e');
      })
      ..setLooping(true)
      ..play();
  }

  void _toggleMute(int index) {
    if (_controllers.containsKey(index)) {
      setState(() {
        _isMuted[index] = !_isMuted[index]!;
        _controllers[index]?.setVolume(_isMuted[index]! ? 0.0 : 1.0);
      });
    }
  }

  Future<String> downloadVideo(String videoUrl) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final videoFile = File('${directory.path}/${videoUrl.split('/').last}');

      if (await videoFile.exists()) {
        return videoFile.path;
      }

      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        await videoFile.writeAsBytes(response.bodyBytes);
        return videoFile.path;
      } else {
        throw Exception("Failed to download video");
      }
    } catch (e) {
      throw Exception("Error downloading video: $e");
    }
  }

  bool isVideo(String mediaUrl) {
    // List of supported video file extensions
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv', '.webm'];

    // Extract the file extension from the URL
    final urlWithoutParams = mediaUrl.split('?').first;

    final urlExtension = urlWithoutParams.split('.').last.toLowerCase();

    // Check if the file extension is in the list of video formats
    return videoExtensions.contains('.$urlExtension');
  }

  Future<void> _checkIfLiked(String postId, String userId) async {
    final postProvider = PostProvider();

    bool liked = await postProvider.isPostLiked(postId, userId);
    setState(() {
      isLiked = liked;
    });
  }

  Future<void> _checkIfSaved(String postId, String userId) async {
    final postProvider = PostProvider();

    bool saved = await postProvider.isPostSaved(postId, userId);
    setState(() {
      isSaved = saved;
    });
  }

  void displaySheet(BuildContext context, String postId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.55,
          maxChildSize: 1,
          snap: true,
          expand: false,
          snapSizes: const [
            0.55,
            1,
          ],
          builder: (BuildContext context, ScrollController scrollController) {
            return Scaffold(
                body: CommentSection(
              scrollController:
                  scrollController, // Pass the scroll controller to CommentSection
              postId: postId, // Pass the post ID to CommentSection
            ));
          },
        );
      },
    );
  }

  Future<void> _deletePost(String postId) async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    await postProvider.deletePost(postId, context);

    Navigator.pop(context, true);
    Navigator.pop(context, true);
  }

  Future<void> submitPollInteraction(
      String postId, String selectedOption) async {
    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;
      final pollProvider = PollProvider();

      if (userId == null) {
        print("User is not authenticated");
        return;
      }

      await pollProvider.submitPollInteraction(postId, selectedOption);

      final results = await pollProvider.getPollResults(postId);

      setState(() {
        voted = true;
        pollResults = results;
      });
      print("Poll interaction submitted successfully!");
    } catch (e) {
      print("Error submitting poll interaction: $e");
    }
  }

  Future<Map<String, int>> getPollResults(String pollId) async {
    try {
      // Fetch all interactions for the specific pollId
      final pollProvider = PollProvider();

      Map<String, int> results = await pollProvider.getPollResults(pollId);
      return results;
    } catch (e) {
      print("Error fetching poll results: $e");
      return {};
    }
  }

  String calculatePercentage(String option) {
    int totalVotes = pollResults.values.fold(0, (sum, count) => sum + count);
    if (totalVotes == 0 || !pollResults.containsKey(option)) return "0%";
    double percentage = (pollResults[option]! / totalVotes) * 100;
    return "${percentage.toStringAsFixed(1)}%";
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    String postAuthorId = widget.post.userId;
    final user = FirebaseAuth.instance.currentUser;
    String currentUserId = user!.uid;

    String username = userProvider.otherUserModel?.username ?? '';

    if (postAuthorId != currentUserId && username.isEmpty) {
      userProvider.fetchUserDetails(postAuthorId);
    }

    return GestureDetector(
        onTap: () {
          // Unfocus when tapping anywhere outside the form
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                Text(
                  postAuthorId == currentUserId ? "My Post" : "",
                ),
                if (postAuthorId != currentUserId)
                  GestureDetector(
                    onTap: () {
                      if (_controllers.containsKey(_currentPage) &&
                          _controllers[_currentPage]!.value.isInitialized) {
                        _controllers[_currentPage]!.pause();
                      }

                      // Navigate to the user profile page when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserProfilePage(
                            userId: postAuthorId ?? '',
                          ),
                        ),
                      );
                    },
                    child: username.isEmpty
                        ? Center(
                            child: Shimmer.fromColors(
                              baseColor: Colors.grey[300]!,
                              highlightColor: Colors.grey[100]!,
                              child: Container(
                                width: 200,
                                height: 20,
                                color: Colors.white,
                              ),
                            ),
                          )
                        : Row(
                            children: [
                              CircleAvatar(
                                radius: 18,
                                backgroundColor: Colors.grey,
                                backgroundImage:
                                    NetworkImage(userProvider.profilePicUrl),
                                child: username == ''
                                    ? null
                                    : Text(
                                        username.substring(0, 1).toUpperCase(),
                                        style: TextStyle(color: Colors.white),
                                      ),
                              ),
                              SizedBox(width: 10),
                              Text(
                                "@${userProvider.otherUserModel?.username}",
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              ),
                            ],
                          ),
                  ),
                Spacer(),
                if (postAuthorId == currentUserId)
                  IconButton(
                    icon: Icon(Icons.more_vert),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16.0)),
                        ),
                        builder: (context) {
                          return FractionallySizedBox(
                            heightFactor: 0.15,
                            child: ListView(
                              children: [
                                ListTile(
                                  leading: Icon(Icons.edit),
                                  title: Text('Edit Post'),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditPostPage(postId: _id),
                                      ),
                                    );
                                  },
                                ),
                                ListTile(
                                  leading:
                                      Icon(Icons.delete, color: Colors.red),
                                  title: Text('Delete Post',
                                      style: TextStyle(color: Colors.red)),
                                  onTap: () async {
                                    // Confirm delete action
                                    bool? confirm = await showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text('Delete Post'),
                                          content: Text(
                                              'Are you sure you want to delete this post?'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text('Cancel'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(false);
                                              },
                                            ),
                                            TextButton(
                                              child: Text('Delete',
                                                  style: TextStyle(
                                                      color: Colors.red)),
                                              onPressed: () {
                                                Navigator.of(context).pop(true);
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );

                                    if (confirm == true) {
                                      // Call your delete function here
                                      await _deletePost(_id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
              ],
            ),
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            color: Colors.white,
            backgroundColor: const Color.fromARGB(255, 159, 118, 249),
            child: ListView(
              padding: const EdgeInsets.only(top: 16.0),
              children: [
                Center(
                  child: SizedBox(
                    height: 400,
                    width: 500,
                    child: PageView.builder(
                      itemCount: widget.post.media.length,
                      itemBuilder: (context, index) {
                        var media = widget.post.media[index];

                        if (isVideo(media)) {
                          if (!_controllers.containsKey(index)) {
                            downloadVideo(media).then((videoPath) {
                              setState(() {
                                _controllers[index] =
                                    getVideoController(videoPath);
                              });
                            }).catchError((error) {
                              print('Error downloading video: $error');
                            });
                          }

                          return Stack(
                            children: [
                              Center(
                                child: _controllers[index] != null &&
                                        _controllers[index]!.value.isInitialized
                                    ? AspectRatio(
                                        aspectRatio: _controllers[index]!
                                            .value
                                            .aspectRatio,
                                        child:
                                            VideoPlayer(_controllers[index]!),
                                      )
                                    : CircularProgressIndicator(
                                        color:
                                            Color.fromARGB(255, 159, 118, 249),
                                      ),
                              ),
                              Positioned(
                                bottom: 20,
                                left: 20,
                                child: GestureDetector(
                                  onTap: () => _toggleMute(index),
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[700],
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      _isMuted[index] == true
                                          ? Icons.volume_off
                                          : Icons.volume_up,
                                      color: Colors.white,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          );
                        } else {
                          return Center(
                            child: Image.network(
                              media,
                              fit: BoxFit.contain,
                            ),
                          );
                        }
                      },
                      onPageChanged: (index) {
                        setState(() {
                          _currentPage = index;
                        });

                        if (_controllers.containsKey(_currentPage) &&
                            _controllers[_currentPage]!.value.isInitialized) {
                          _controllers[_currentPage]!.pause();
                        }

                        if (_controllers.containsKey(index) &&
                            _controllers[index]!.value.isInitialized) {
                          _controllers[index]!.play();
                        }
                      },
                    ),
                  ),
                ),
                SizedBox(height: 30),
                // Dot indicators
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    widget.post.media.length,
                    (index) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? Color.fromARGB(255, 159, 118, 249)
                              : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Post details section
                Padding(
                  padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        _description,
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),

                      // Poll
                      if (_pollQuestion != '')
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 400,
                              padding: EdgeInsets.all(16.0),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white.withOpacity(0.3)
                                      : Colors.black.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _pollQuestion ?? '', // Poll Question
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  // Poll Options (Display as buttons or other UI elements)
                                  if (_pollOptions != null &&
                                      _pollOptions!.isNotEmpty)
                                    for (int i = 0;
                                        i < _pollOptions!.length;
                                        i++)
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            if (voted == false) {
                                              submitPollInteraction(
                                                  widget.id, _pollOptions![i]);

                                              setState(() {
                                                _selectedOption =
                                                    _pollOptions![i];
                                              });
                                            }
                                          },
                                          style: ElevatedButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 12.0,
                                                horizontal: 24.0),
                                            backgroundColor: (_selectedOption ==
                                                        _pollOptions![i] ||
                                                    fetchedSelectedOption ==
                                                        _pollOptions![i])
                                                ? const Color.fromARGB(
                                                    255, 159, 118, 249)
                                                : (Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.grey[500]
                                                    : Colors.grey[300]),
                                            minimumSize:
                                                Size(double.infinity, 50),
                                          ),
                                          child: Align(
                                              alignment: Alignment.centerLeft,
                                              child: (_selectedOption ==
                                                          _pollOptions![i] ||
                                                      fetchedSelectedOption ==
                                                          _pollOptions![i])
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          _pollOptions![i],
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        if (voted == true)
                                                          Text(
                                                            calculatePercentage(
                                                                _pollOptions![
                                                                    i]),
                                                            style: TextStyle(
                                                              color: (_selectedOption ==
                                                                          _pollOptions![
                                                                              i] ||
                                                                      fetchedSelectedOption ==
                                                                          _pollOptions![
                                                                              i])
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          ),
                                                      ],
                                                    )
                                                  : Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceBetween,
                                                      children: [
                                                        Text(
                                                          _pollOptions![i],
                                                          textAlign:
                                                              TextAlign.left,
                                                        ),
                                                        if (voted == true)
                                                          Text(
                                                            calculatePercentage(
                                                                _pollOptions![
                                                                    i]),
                                                            style: TextStyle(
                                                              color: (_selectedOption ==
                                                                          _pollOptions![
                                                                              i] ||
                                                                      fetchedSelectedOption ==
                                                                          _pollOptions![
                                                                              i])
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black,
                                                            ),
                                                          )
                                                      ],
                                                    )),
                                        ),
                                      ),
                                  // Clear Vote Button
                                  if (voted == true)
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: SizedBox(
                                        height:
                                            30, // Adjust height to fit the button snugly
                                        child: TextButton(
                                          onPressed: () async {
                                            String? userId = FirebaseAuth
                                                .instance.currentUser?.uid;

                                            try {
                                              await pollProvider.clearUserVote(
                                                  widget.id, userId!);
                                            } catch (e) {
                                              print("Error clearing vote: $e");
                                              setState(() {
                                                voted = true;
                                              });
                                            }

                                            setState(() {
                                              _selectedOption = null;
                                              fetchedSelectedOption = null;
                                              voted = false;
                                            });
                                          },
                                          style: TextButton.styleFrom(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8.0, vertical: 0.0),
                                          ),
                                          child: Text("Clear Vote"),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      if (_pollQuestion != '') SizedBox(height: 15),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            formattedDate,
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                          ),
                          SizedBox(width: 8),
                          _location.isNotEmpty
                              ? Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: Colors.grey[500],
                                )
                              : SizedBox.shrink(),
                          SizedBox(width: 8),
                          Text(
                            (_location.length) > 15
                                ? "${_location.substring(0, 15)}..."
                                : (_location),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 4),
                  height: 2,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[300],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    IconButton(
                      icon: Icon(
                        isLiked ? Icons.favorite : Icons.favorite_border,
                        size: 30,
                        color: isLiked ? Colors.red : null,
                      ),
                      onPressed: () async {
                        final postId = _id;
                        final userId = userProvider.user!.uid;

                        setState(() {
                          isLiked = !isLiked;
                          likeCount = isLiked ? likeCount + 1 : likeCount - 1;
                        });

                        PostProvider postProvider = PostProvider();
                        await postProvider.likePost(postId, userId);
                      },
                    ),
                    Text("$likeCount", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(Icons.mode_comment_outlined, size: 30),
                      onPressed: () {
                        final postId = _id;
                        displaySheet(context, postId);
                        // showModalBottomSheet(
                        //   context: context,
                        //   isScrollControlled: true,
                        //   shape: RoundedRectangleBorder(
                        //     borderRadius:
                        //         BorderRadius.vertical(top: Radius.circular(16)),
                        //   ),
                        //   builder: (BuildContext context) {
                        //     return DraggableScrollableSheet(
                        //       initialChildSize: 0.55,
                        //       maxChildSize: 1,
                        //       snap: true,
                        //       expand: false,
                        //       snapSizes: const [
                        //         0.55,
                        //         1,
                        //       ],
                        //       builder: (BuildContext context,
                        //           ScrollController scrollController) {
                        //         return CommentSection(
                        //             scrollController: scrollController,
                        //             postId: _id);
                        //       },
                        //     );
                        //   },
                        // );
                      },
                    ),
                    Text("$commentCount", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 10),
                    IconButton(
                      icon: Icon(
                          isSaved
                              ? Icons.bookmark
                              : Icons.bookmark_border_outlined,
                          size: 30,
                          color: isSaved
                              ? const Color.fromARGB(246, 247, 195, 9)
                              : null),
                      onPressed: () async {
                        final postId = _id;
                        final userId = userProvider.user!.uid;

                        setState(() {
                          isSaved = !isSaved;
                          saveCount = isSaved ? saveCount + 1 : saveCount - 1;
                        });

                        PostProvider postProvider = PostProvider();
                        await postProvider.savePost(postId, userId);
                      },
                    ),
                    Text("$saveCount", style: TextStyle(fontSize: 16)),
                    SizedBox(width: 15),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        ));
  }
}
