import 'package:flutter/material.dart';

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Full-Screen Image'),
        backgroundColor: Colors.black,
      ),
      body: Center(
        child: Image.network(
          imageUrl,
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) => const Text(
            'Failed to load image',
            style: TextStyle(color: Colors.red),
          ),
        ),
      ),
      backgroundColor: Colors.black, // Makes the background of the full-screen view black
    );
  }
}
