import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class ImagePreviewScreen extends StatefulWidget {
  final List<File> images;
  final int initialIndex;

  ImagePreviewScreen({required this.images, required this.initialIndex});

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
                  itemCount: widget.images.length,
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    File image = widget.images[index];
                    return Center(
                      child: Image.file(
                        image,
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
