import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<File> files;
  final int initialIndex;

  ImagePreviewScreen({required this.files, required this.initialIndex});

  @override
  _ImagePreviewScreenState createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Preview'),
          leading: IconButton(
            icon: Icon(Icons.close), // Close button
            onPressed: () {
              Navigator.pop(context); // Close the preview screen
            },
          ),
        ),
        body: SafeArea(
          minimum: const EdgeInsets.only(bottom: 60),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  itemCount: widget.files.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    File file = widget.files[index];
                    final isVideo =
                        file.path.endsWith('.mp4') || // Detect video
                            file.path.endsWith('.mkv') ||
                            file.path.endsWith('.avi');

                    return Center(
                      child: isVideo
                          ? VideoPreview(file: file)
                          : Image.file(
                              file,
                              fit: BoxFit.contain,
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ));
  }
}

class VideoPreview extends StatefulWidget {
  final File file;

  VideoPreview({required this.file});

  @override
  _VideoPreviewState createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> {
  late VideoPlayerController _videoController;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _videoController = VideoPlayerController.file(widget.file)
      ..initialize().then((_) {
        setState(() {});
        _videoController.play();
        _videoController.setLooping(true);
      });
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
      _videoController
          .setVolume(_isMuted ? 0.0 : 1.0); // Mute or unmute the video
    });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _videoController.value.isInitialized
        ? Stack(
            children: [
              // Video player
              AspectRatio(
                aspectRatio: _videoController.value.aspectRatio,
                child: VideoPlayer(_videoController),
              ),
              // Mute/Unmute Icon
              Positioned(
                bottom: 20,
                left: 20,
                child: GestureDetector(
                  onTap: _toggleMute,
                  child: Container(
                    padding: EdgeInsets.all(8), // Space around the icon
                    decoration: BoxDecoration(
                      color: Colors.grey[700], // Background color
                      shape: BoxShape.circle, // Circular background
                    ),
                    child: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white, // Icon color
                      size: 30, // Icon size
                    ),
                  ),
                ),
              ),
            ],
          )
        : Center(
            child: CircularProgressIndicator(
                color: Color.fromARGB(255, 159, 118, 249)),
          );
  }
}
