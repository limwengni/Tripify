import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/views/image_preview_page.dart';
import 'package:tripify/views/preview_post_page.dart';
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

  List<String> _tags = [
    'Travel',
    'Adventure',
    'Nature',
    'Photography',
    'Hiking'
  ];

  final int _maxTitleLength = 20;

  @override
  void initState() {
    super.initState();

    _titleController.addListener(() {
      // If the bio exceeds the maximum length, we trim it
      if (_titleController.text.length > _maxTitleLength) {
        _titleController.text =
            _titleController.text.substring(0, _maxTitleLength);
        // Move the cursor to the end of the text
        _titleController.selection = TextSelection.fromPosition(
            TextPosition(offset: _titleController.text.length));
      }
      setState(() {}); // Trigger a rebuild to show the character count
    });
  }

  void _showImagePreview(File initialImage) {
    int initialIndex = widget.imagesWithIndex.keys
        .toList()
        .indexOf(initialImage); // Get the clicked image index

    // Navigate to the ImagePreviewScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
          images:
              widget.imagesWithIndex.keys.toList(), // Pass the list of images
          initialIndex: initialIndex, // Pass the initial image index
        ),
      ),
    );
  }

  Future<void> _savePost() async {
    // Validate if fields are empty
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Please fill in all fields')));
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
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error saving post: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text("New Post"),
            // actions: [
            //   IconButton(
            //     icon: Icon(Icons.check),
            //     onPressed: _savePost, // Trigger saving the post
            //   ),
            // ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Display images in a grid, showing the image and its index (if needed)
                  widget.imagesWithIndex.isNotEmpty
                      ? SingleChildScrollView(
                          scrollDirection:
                              Axis.horizontal, // Allow horizontal scrolling
                          child: Row(
                            children: widget.imagesWithIndex.keys.map((image) {
                              return Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          4), // Minimal gap between images
                                  child: GestureDetector(
                                    onTap: () {
                                      // Open preview mode in a dialog when the image is tapped
                                      _showImagePreview(image);
                                    },
                                    child: ClipRRect(
                                        child: Container(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? Colors.grey[800]
                                          : Colors.grey[200],
                                      child: Image.file(
                                        image,
                                        width:
                                            200, // Set width for square shape
                                        height:
                                            200, // Set height for square shape
                                        fit: BoxFit
                                            .contain, // Ensure image covers the box
                                      ),
                                    )),
                                  ));
                            }).toList(),
                          ),
                        )
                      : Text('No images selected'),

                  SizedBox(height: 20),

                  // Title TextField
                  TextFormField(
                      cursorColor:
                          Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black,
                      maxLength: 20,
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Add a title',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        counterText: "",
                        // Custom counter showing remaining characters
                        suffixText:
                            '${_maxTitleLength - _titleController.text.length}',
                        suffixStyle: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a username';
                        }

                        if (value.length > 20) {
                          return 'Title cannot exceed 20 characters';
                        }

                        return null;
                      }),
                  Container(
                    margin:
                        EdgeInsets.only(top: 4), // Optional margin for spacing
                    height: 2, // Height of the divider
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300], // Color of the divider
                  ),
                  SizedBox(height: 16),

                  // Description TextField
                  TextFormField(
                    cursorColor: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    controller: _descriptionController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: 'Add description',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a description';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 5),
                  // Hashtag place
                  SingleChildScrollView(
                    scrollDirection:
                        Axis.horizontal, // Enables horizontal scrolling
                    child: Row(
                      children: _tags.map((tag) {
                        return GestureDetector(
                            onTap: () {
                              // Append hashtag to the description
                              String currentText = _descriptionController.text;

                              if (currentText.isNotEmpty) {
                                _descriptionController.text =
                                    '$currentText #$tag';
                              } else {
                                _descriptionController.text = '#$tag';
                              }

                              _descriptionController.selection =
                                  TextSelection.fromPosition(
                                TextPosition(
                                    offset: _descriptionController.text.length),
                              );

                              setState(() {
                                _tags.remove(
                                    tag); // Remove the selected tag from the list
                              });
                            },
                            child: Container(
                              margin: const EdgeInsets.only(
                                  right: 8), // Space between pills
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.grey[
                                        300], // Background color of the pill
                                borderRadius: BorderRadius.circular(
                                    16), // Rounded corners
                              ),
                              child: Text(
                                '#$tag',
                                style: TextStyle(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.grey[300]
                                      : Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ));
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 5),
                  Container(
                    margin:
                        EdgeInsets.only(top: 4), // Optional margin for spacing
                    height: 2, // Height of the divider
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.grey[800]
                        : Colors.grey[300], // Color of the divider
                  ),

                  Padding(
                    padding: const EdgeInsets.only(top: 14, bottom: 14),
                    child: GestureDetector(
                      onTap: () {
                        // Action when tapped, e.g., show a location picker or map.
                        print("location");
                      },
                      child: Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined, // Location icon
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black, // Color of the icon
                            size: 24, // Size of the icon
                          ),
                          SizedBox(width: 8), // Space between icon and text
                          Expanded(
                            child: Text(
                              'Mark location', // The text
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios, // Right arrow icon
                            size: 18,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.grey[800]
                                    : Colors.black, // Color of the arrow
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Post and Preview Buttons in a Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Distribute space between buttons
                    children: [
                      // Preview Button
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the PostFormPage and pass data
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PostFormPage(
                                title: _titleController.text, // Pass the title
                                description: _descriptionController
                                    .text, // Pass the description
                                imagesWithIndex:
                                    widget.imagesWithIndex, // Pass the images (you may need to format this if needed)
                                location: "_location", // Pass the location
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 159, 118, 249),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text('Preview', style: TextStyle(fontSize: 16)),
                      ),

                      // Post Button
                      ElevatedButton(
                        onPressed: _savePost, // Save post
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 159, 118, 249),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text('Post', style: TextStyle(fontSize: 16)),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
