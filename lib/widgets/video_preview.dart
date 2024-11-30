import 'package:flutter/material.dart';
import 'package:tripify/widgets/full_screen_video_player.dart';
import 'package:video_player/video_player.dart';

class VideoPreview extends StatefulWidget {
  final String videoPath;
  final bool isCurrentUser;

  const VideoPreview({
    super.key,
    required this.videoPath,
    required this.isCurrentUser,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoPath)
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                FullScreenVideoPlayer(videoPath: widget.videoPath),
          ),
        );
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Show a circular progress indicator while loading
          if (!_isInitialized)
            Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.grey[200], // Background for loading placeholder
              ),
              child: const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                  strokeWidth: 3.0,
                ),
              ),
            )
          else
            // Show the video player preview after initialization
            Container(
              height: 200,
              width: 200,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_controller),
              ),
            ),
          // Always show the play icon overlay
          const Icon(
            Icons.play_circle_fill,
            color: Colors.white,
            size: 50,
          ),
        ],
      ),
    );
  }
}
