import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/views/profile_page.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/view_models/post_provider.dart';

class PostFormPage extends StatefulWidget {
  final String title;
  final String? description;
  final Map<File, int> imagesWithIndex;
  final String? location;

  // Constructor to receive the parameters
  PostFormPage({
    required this.title,
    this.description,
    required this.imagesWithIndex,
    this.location,
  });

  @override
  _PostFormPageState createState() => _PostFormPageState();
}

class _PostFormPageState extends State<PostFormPage> {
  late String _title;
  late String? _description;
  late String? _location;
  late Map<File, int> _imagesWithIndex;
  late int _numOfImages;
  String location = "";
  List<bool> _isMuted = [];

  int likeCount = 0;
  int commentCount = 0;
  int saveCount = 0;

  late PageController _pageController;
  Map<int, VideoPlayerController> _controllers = {};

  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the passed data
    _title = widget.title;
    _description = widget.description ?? "";
    _location = widget.location ?? "";
    _imagesWithIndex = widget.imagesWithIndex;

    _pageController = PageController();
    _isMuted =
        List.generate(widget.imagesWithIndex.keys.length, (index) => false);
  }

  bool isVideo(File file) {
    final videoExtensions = ['.mp4', '.mov', '.avi', '.mkv'];
    return videoExtensions.any((ext) => file.path.endsWith(ext));
  }

  VideoPlayerController getVideoController(File videoFile) {
    return VideoPlayerController.file(videoFile)
      ..initialize().then((_) {
        setState(() {});
      })
      ..setLooping(true)
      ..play();
  }

  void _toggleMute(int index) {
    setState(() {
      _isMuted[index] =
          !_isMuted[index]; // Toggle the mute state for the selected video
      _controllers[index]!
          .setVolume(_isMuted[index] ? 0.0 : 1.0); // Mute or unmute the video
    });
  }

  void _showCustomSnackbar() {
    final snackBar = Material(
      color: Colors.transparent, // Make background transparent
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8), // Background color of pill
          borderRadius: BorderRadius.circular(30), // Pill shape
        ),
        child: Text(
          "You are in preview mode",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(child: snackBar);
      },
    );

    Future.delayed(Duration(seconds: 2), () {
      Navigator.of(context).pop(); // Dismiss the dialog (snackbar)
    });
  }

  void _submitPost() async {
    // Filter out the hashtag from description then store in list
    String title = _title;
    String description = _description ?? "";
    List<String> hashtags =
        description.isNotEmpty ? _extractHashtags(description) : [];
    Map<File, int> imagesWithIndex = _imagesWithIndex;
    String? location = _location;

    String descriptionWithEscapedNewlines =
        description.replaceAll('\n', '\\n').trim();

    PostProvider postProvider = PostProvider();

    try {
      String? userId = FirebaseAuth.instance.currentUser?.uid;

      if (userId == null) {
        print("User is not authenticated");
        return;
      }

      await postProvider.submitPost(
        userId: userId,
        title: title,
        description: descriptionWithEscapedNewlines,
        mediaWithIndex: imagesWithIndex,
        hashtags: hashtags,
        location: location,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post submitted successfully!',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        ),
      );

      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
    } catch (e) {
      print("Error submitting post: $e");
    }
  }

  List<String> _extractHashtags(String description) {
    RegExp hashtagRegex = RegExp(r'#\w+');
    return hashtagRegex
        .allMatches(description)
        .map((match) => match.group(0)!.substring(1))
        .toList();
  }

  @override
  void dispose() {
    _pageController.dispose();

    _controllers.forEach((index, controller) {
      controller.pause();
      controller.setVolume(0.0);
      controller.dispose();
    });
    _controllers.clear();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(top: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: SizedBox(
              height: 400,
              width: 500,
              child: PageView.builder(
                controller: PageController(),
                itemCount: widget.imagesWithIndex.keys.length,
                itemBuilder: (context, index) {
                  File file = widget.imagesWithIndex.keys.elementAt(index);

                  if (isVideo(file)) {
                    // Initialize video controller for the current visible video
                    if (!_controllers.containsKey(index)) {
                      // If controller for this index does not exist, create a new one
                      _controllers[index] = getVideoController(file);
                    }

                    return Stack(
                      children: [
                        // Video Player
                        Center(
                          child: _controllers[index] != null &&
                                  _controllers[index]!.value.isInitialized
                              ? AspectRatio(
                                  aspectRatio:
                                      _controllers[index]!.value.aspectRatio,
                                  child: VideoPlayer(_controllers[index]!),
                                )
                              : CircularProgressIndicator(
                                  color: Color.fromARGB(255, 159, 118,
                                      249)), // Show loading while initializing
                        ),

                        // Mute/Unmute Icon
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: GestureDetector(
                            onTap: () => _toggleMute(
                                index), // Call _toggleMute when tapped
                            child: Container(
                              padding:
                                  EdgeInsets.all(8), // Space around the icon
                              decoration: BoxDecoration(
                                color: Colors.grey[700], // Background color
                                shape: BoxShape.circle, // Circular background
                              ),
                              child: Icon(
                                _isMuted[index]
                                    ? Icons.volume_off
                                    : Icons.volume_up,
                                color: Colors.white, // Icon color
                                size: 25, // Icon size
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  } else {
                    // If the file is an image, display it normally
                    return Center(
                      child: Image.file(
                        file,
                        fit: BoxFit.contain,
                      ),
                    );
                  }
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });

                  _controllers.forEach((key, controller) {
                    if (key != index && controller.value.isInitialized) {
                      controller.pause();
                      controller.setVolume(0.0);
                    }
                  });

                  // Dispose of the video controller when it's no longer needed
                  if (_controllers.containsKey(index)) {
                    File file = widget.imagesWithIndex.keys.elementAt(index);
                    if (isVideo(file)) {
                      _controllers[index] = getVideoController(file);
                    }
                  } else {
                    final controller = _controllers[index];
                    if (controller!.value.isInitialized) {
                      controller.play();
                      controller.setVolume(1.0);
                    }
                  }
                },
              ),
            )),

            SizedBox(height: 30),
            // Dot indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.imagesWithIndex.length,
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

            // Post details
            Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        "$_title",
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),

                      // Description
                      Text(
                        "$_description",
                        style: TextStyle(fontSize: 18),
                      ),
                      SizedBox(height: 10),

                      // Sample time and Location (if available)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            "Just now",
                            style: TextStyle(
                                fontSize: 16, color: Colors.grey[500]),
                          ),
                          SizedBox(width: 8),
                          _location != ''  // Check if _location is not null and not empty
                              ? Icon(
                                  Icons.circle,
                                  size: 5,
                                  color: Colors.grey[500],
                                )
                              : SizedBox.shrink(),
                          SizedBox(width: 8),
                          Text(
                            (_location?.length ?? 0) > 15
                                ? "${_location?.substring(0, 15)}..."
                                : (_location ?? ''),
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                          )
                        ],
                      ),
                      SizedBox(height: 20),
                    ])),

            Container(
              margin: EdgeInsets.only(top: 4), // Optional margin for spacing
              height: 2, // Height of the divider
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[300], // Color of the divider
            ),

            Row(
              mainAxisAlignment: MainAxisAlignment.end, // Align to the right
              children: [
                // Like icon
                IconButton(
                  icon: Icon(Icons.favorite_border, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are in preview mode.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 159, 118, 249),
                      ),
                    );
                  },
                ),
                Text("$likeCount", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10), // Space between icons

                // Comment icon
                IconButton(
                  icon: Icon(Icons.mode_comment_outlined,
                      size: 30), // Comment icon
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are in preview mode.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 159, 118, 249),
                      ),
                    );
                  },
                ),
                Text("$commentCount", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10), // Space between icons

                // Save icon
                IconButton(
                  icon: Icon(Icons.bookmark_border_outlined,
                      size: 30), // Save icon
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are in preview mode.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor:
                            const Color.fromARGB(255, 159, 118, 249),
                      ),
                    );
                  },
                ),
                Text("$saveCount", style: TextStyle(fontSize: 16)),
                SizedBox(width: 15),
              ],
            ),

            SizedBox(height: 20),

            Container(
              margin: EdgeInsets.only(top: 4), // Optional margin for spacing
              height: 2, // Height of the divider
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[800]
                  : Colors.grey[300], // Color of the divider
            ),
            SizedBox(height: 20),

            // Post button
            Center(
              child: ElevatedButton(
                onPressed: _submitPost, // Trigger the post submission
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(255, 159, 118, 249),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                ),
                child: Text("Post", style: TextStyle(fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
