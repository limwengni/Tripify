import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/view_models/post_provider.dart'; // Import PostService

class NewPostPage extends StatefulWidget {
  final List<File> images;

  NewPostPage({required this.images});

  @override
  _NewPostPageState createState() => _NewPostPageState();
}

class _NewPostPageState extends State<NewPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _savePost() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
      return;
    }

    final newPost = Post(
      userId: 'User/uid',
      title: _titleController.text,
      description: _descriptionController.text,
      createdAt: DateTime.now(),
      updatedAt: null,
      media: [],
      likesCount: 0,
      commentsCount: 0,
      savedCount: 0,
    );

    final postProvider = Provider.of<PostProvider>(context, listen: false);

    try {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Call the createPost method to save the post
        await postProvider.createPost(user.uid, newPost, widget.images);
      }

      // Clear the fields and go back
      _titleController.clear();
      _descriptionController.clear();

      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving post')));
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
            onPressed: _savePost,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              // Display the selected images in a grid
              widget.images.isNotEmpty
                  ? GridView.builder(
                      shrinkWrap: true,
                      itemCount: widget.images.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 8,
                        mainAxisSpacing: 8,
                      ),
                      itemBuilder: (context, index) {
                        return Image.file(widget.images[index],
                            fit: BoxFit.cover);
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
