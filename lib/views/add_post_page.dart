import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/view_models/post_provider.dart'; // Import PostService

class NewPostPage extends StatefulWidget {
  final Map<File, int> imagesWithIndex; // Accept Map<File, int>

  NewPostPage({required this.imagesWithIndex});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _savePost() async {
    // Validate if fields are empty
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill in all fields')
      ));
      return;
    }

    final newPost = Post(
      userId: FirebaseAuth.instance.currentUser?.uid ?? 'unknown_user',
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
      updatedAt: null,
      media: [], // This will be updated with media URLs later
      likesCount: 0,
      commentsCount: 0,
      savedCount: 0,
    );

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Call the createPost method to save the post, passing images and media
        // await postProvider.createPost(user.uid, newPost, widget.imagesWithIndex);
      }

      // Clear fields and navigate back after saving
      _titleController.clear();
      _descriptionController.clear();

      Navigator.pop(context);
    } catch (e) {
      // Handle errors when saving the post
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error saving post: $e')
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create a New Post"),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _savePost, // Trigger saving the post
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title TextField
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              
              // Description TextField
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              
              // Display images in a grid, showing the image and its index (if needed)
              widget.imagesWithIndex.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true, // To make sure grid doesn't overflow
                      itemCount: widget.imagesWithIndex.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 3 images per row
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        File image = widget.imagesWithIndex.keys.toList()[index];
                        int imageIndex = widget.imagesWithIndex.values.toList()[index];
                        return Column(
                          children: [
                            Image.file(image, fit: BoxFit.cover),
                            SizedBox(height: 4),
                            Text('Index: $imageIndex'), // Show index or other data
                          ],
                        );
                      },
                    )
                  : Text('No images selected'),
            ],
          ),
        ),
      ),
    );
  }
}
