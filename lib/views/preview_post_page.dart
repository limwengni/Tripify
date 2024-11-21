import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
  late int _numOfImages;

  late PageController _pageController;
  int _currentPage = 0;

  double? _imageHeight;

  @override
  void initState() {
    super.initState();
    // Initialize the controllers with the passed data
    _title = widget.title;
    _description = widget.description ?? null;
    _location = widget.location ?? null;
    _numOfImages = widget.imagesWithIndex.length;

    _pageController = PageController();
  }

  void _submitPost() {
    // Implement your actual post submission logic here
    print("Post submitted!");
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Preview Post")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 300,
              child: PageView.builder(
                itemCount: widget.imagesWithIndex.keys.length,
                itemBuilder: (context, index) {
                  File image = widget.imagesWithIndex.keys.elementAt(index);
                  return Center(
                    child: Image.file(image, fit: BoxFit.contain),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index; // Update the current page index
                  });
                },
              ),
            ),

            SizedBox(height: 25),
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
                      color: _currentPage == index ? Color.fromARGB(255, 159, 118, 249) : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Title
            Text(
              "$_title",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Description
            Text(
              "$_description",
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),

            // Location (if available)
            Text(
              "$_location",
              style: TextStyle(fontSize: 16),
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
