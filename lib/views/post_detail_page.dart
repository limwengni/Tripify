import 'dart:io';
import 'dart:ui';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/models/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_network_image/cached_network_image.dart';

class PostDetailPage extends StatefulWidget {
  final Post post;

  // Constructor to accept the post object
  PostDetailPage({required this.post});

  @override
  _PostDetailPageState createState() => _PostDetailPageState();
}

class _PostDetailPageState extends State<PostDetailPage> {
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

  @override
  void initState() {
    super.initState();

    // Initialize post details from widget.post
    _title = widget.post.title;
    _description = widget.post.description ?? '';
    _location = widget.post.location ?? '';
    likeCount = widget.post.likesCount;
    commentCount = widget.post.commentsCount;
    saveCount = widget.post.savedCount;
    _createdAt = widget.post.createdAt;

    _description = _description.replaceAll(r'\n', '\n');

    formattedDate = formatPostDate(_createdAt.toLocal());

    for (int i = 0; i < widget.post.media.length; i++) {
      print('Media $i: ${widget.post.media[i]}');
      print(isVideo(widget.post.media[i]));
    }

    for (int i = 0; i < widget.post.media.length; i++) {
      _isMuted[i] = false;
    }
  }

  String formatPostDate(DateTime createdAt) {
    DateTime now = DateTime.now();

    print('NOW: $now');
    DateTime localCreatedAt = createdAt.toLocal();
    print('localCreatedAt: $localCreatedAt');

    Duration difference = now.difference(localCreatedAt);

    if (difference.inDays < 1) {
      if (difference.inHours < 1) {
        return "Just Now";
      } else {
        return "${difference.inHours} Hour${difference.inHours > 1 ? 's' : ''} Ago";
      }
    } else if (difference.inDays == 1) {
      return "1 Day Ago"; // After 1 day then show date
    } else {
      return DateFormat('d MMMM yyyy').format(localCreatedAt); // "4 August 2023"
    }
  }

  @override
  void dispose() {
    // Dispose of controllers when done
    _controllers.forEach((key, controller) {
      controller.dispose();
    });
    super.dispose();
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
        _controllers[index]!.setVolume(_isMuted[index]! ? 0.0 : 1.0);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("My Post")),
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
                itemCount: widget.post.media.length,
                itemBuilder: (context, index) {
                  var media = widget.post.media[index];

                  if (isVideo(media)) {
                    if (!_controllers.containsKey(index)) {
                      downloadVideo(media).then((videoPath) {
                        setState(() {
                          _controllers[index] = getVideoController(videoPath);
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
                                  aspectRatio:
                                      _controllers[index]!.value.aspectRatio,
                                  child: VideoPlayer(_controllers[index]!),
                                )
                              : CircularProgressIndicator(
                                  color: Color.fromARGB(255, 159, 118, 249)),
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
                    // return CachedNetworkImage(
                    //   imageUrl: media,
                    //   placeholder: (context, url) => Shimmer.fromColors(
                    //     baseColor: Colors.grey[300]!,
                    //     highlightColor: Colors.grey[100]!,
                    //     child: Container(
                    //       color: Colors.white,
                    //       width: double.infinity,
                    //     ),
                    //   ),
                    //   errorWidget: (context, url, error) {
                    //     print('Error loading image: $error');
                    //     return Icon(Icons.error);
                    //   },
                    //   width: double.infinity,
                    //   height: double.infinity,
                    //   fit: BoxFit.cover,
                    // );
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
            )),
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
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),
                  Text(
                    _description,
                    style: TextStyle(fontSize: 18),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        formattedDate,
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                      SizedBox(width: 8),
                      if (_location.isNotEmpty)
                        Icon(
                          Icons.circle,
                          size: 5,
                          color: Colors.grey[500],
                        ),
                      SizedBox(width: 8),
                      Text(
                        _location,
                        style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
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
                  icon: Icon(Icons.favorite_border, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are in preview mode.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color.fromARGB(255, 159, 118, 249),
                      ),
                    );
                  },
                ),
                Text("$likeCount", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.mode_comment_outlined, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are in preview mode.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color.fromARGB(255, 159, 118, 249),
                      ),
                    );
                  },
                ),
                Text("$commentCount", style: TextStyle(fontSize: 16)),
                SizedBox(width: 10),
                IconButton(
                  icon: Icon(Icons.bookmark_border_outlined, size: 30),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "You are in preview mode.",
                          style: TextStyle(color: Colors.white),
                        ),
                        backgroundColor: Color.fromARGB(255, 159, 118, 249),
                      ),
                    );
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
    );
  }
}
