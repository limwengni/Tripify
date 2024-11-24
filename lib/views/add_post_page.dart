import 'dart:io';
import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tripify/views/select_location_page.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  late Map<File, ValueNotifier<File?>> thumbnailCache;

  String selectedLocation = '';

  List<String> _tags = [
    'Travel',
    'Adventure',
    'Nature',
    'Photography',
    'Hiking',
    'ABC'
  ];

  // Function to shuffle tags and return a random list
  List<String> _getRandomizedTags() {
    List<String> shuffledTags =
        List.from(_tags); // Copy the list to avoid modifying the original
    shuffledTags.shuffle(Random()); // Shuffle the list
    return shuffledTags;
  }

  final int _maxTitleLength = 20;
  int hashtagCount = 0;
  bool _isListenerEnabled = true;

  @override
  void initState() {
    super.initState();

    thumbnailCache = {};

    // Generate thumbnails for each file asynchronously
    widget.imagesWithIndex.keys.forEach((file) {
      thumbnailCache[file] = ValueNotifier<File?>(null);
      if (isVideo(file)) {
        _generateThumbnail(file); // Generate thumbnail if video
      } else {
        // No thumbnail generation needed for images
        thumbnailCache[file]?.value = file;
      }
    });

    _titleController.addListener(() {
      // If the bio exceeds the maximum length, we trim it
      if (_titleController.text.length > _maxTitleLength) {
        _titleController.text =
            _titleController.text.substring(0, _maxTitleLength);
        _titleController.selection = TextSelection.fromPosition(
            TextPosition(offset: _titleController.text.length));
      }
      setState(() {});
    });

    _descriptionController.addListener(() {
      _checkHashtagLimit(_descriptionController.text);
    });
  }

  void _checkHashtagLimit(String text) {
    // Count the occurrences of `#`
    int count = '#'.allMatches(text).length;

    setState(() {
      hashtagCount = count;

      print("hashtag count: $hashtagCount");

      // If hashtag count exceeds 5, we trim the text or show a warning
      if (hashtagCount > 5) {
        _isListenerEnabled = false;

        // Prevent adding more hashtags, or you could just show a message
        _descriptionController.text = text.substring(0, text.lastIndexOf('#'));
        _descriptionController.selection = TextSelection.fromPosition(
            TextPosition(offset: _descriptionController.text.length));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'You can only use up to 5 hashtags.',
              style: TextStyle(color: Colors.white),
            ),
            duration: Duration(seconds: 2),
            backgroundColor: const Color.fromARGB(255, 159, 118, 249),
          ),
        );

        // Enable the listener again after a delay
        Future.delayed(Duration(milliseconds: 100), () {
          _isListenerEnabled = true;
        });
      }
    });
  }

  bool isVideo(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    return ['mp4', 'mov', 'avi', 'mkv']
        .contains(extension); // Add more video formats if needed
  }

  Future<void> _generateThumbnail(File file) async {
    try {
      final thumbnail = await genThumbnailFile(file.path); // Generate thumbnail
      thumbnailCache[file]?.value =
          thumbnail; // Update the ValueNotifier with the generated thumbnail
    } catch (e) {
      print(
          "Error generating thumbnail: $e"); // Handle any error in thumbnail generation
    }
  }

  Future<File> genThumbnailFile(String path) async {
    final fileName = await VideoThumbnail.thumbnailFile(
      video: path,
      thumbnailPath: (await getTemporaryDirectory()).path,
      maxHeight: 100,
      quality: 75,
    );
    File file = File(fileName.path);
    return file;
  }

  void _showImagePreview(File initialImage) {
    // Preview the asset
    int initialIndex = widget.imagesWithIndex.keys
        .toList()
        .indexOf(initialImage); // Get the clicked image index

    // Navigate to the ImagePreviewScreen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePreviewScreen(
          files:
              widget.imagesWithIndex.keys.toList(), // Pass the list of images
          initialIndex: initialIndex, // Pass the initial image index
        ),
      ),
    );
  }

// Use later..
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

  void _goToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostFormPage(
            title: _titleController.text, // Pass the title
            description: _descriptionController.text, // Pass the description
            imagesWithIndex: widget.imagesWithIndex, // Pass the images
            location: selectedLocation, // Pass the location
            // Pass other required data
          ),
        ),
      );
    } else {
      // Show validation errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Please enter the neccessary details before proceeding.",
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
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
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display images/videos in a grid, showing the asssts and its index (if needed)
                    widget.imagesWithIndex.isNotEmpty
                        ? SingleChildScrollView(
                            scrollDirection:
                                Axis.horizontal, // Allow horizontal scrolling
                            child: Row(
                              children: widget.imagesWithIndex.keys.map((file) {
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  child: GestureDetector(
                                    onTap: () {
                                      _showImagePreview(file);
                                    },
                                    child: ClipRRect(
                                      child: Container(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.grey[800]
                                            : Colors.grey[200],
                                        child: ValueListenableBuilder<File?>(
                                          valueListenable: thumbnailCache[
                                              file]!, // Listen for updates to the thumbnail
                                          builder: (context, thumbnail, child) {
                                            if (thumbnail != null) {
                                              // If the thumbnail is generated, show it
                                              return Image.file(
                                                thumbnail,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.contain,
                                              );
                                            } else {
                                              // If the thumbnail is not ready, show a loading indicator
                                              return Center(
                                                  child:
                                                      CircularProgressIndicator(
                                                          color: Color.fromARGB(
                                                              255,
                                                              159,
                                                              118,
                                                              249)));
                                            }
                                          },
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          )
                        : Text('No assets selected'),

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
                            return 'Please enter the post title';
                          }

                          if (value.length > 20) {
                            return 'Title cannot exceed 20 characters';
                          }

                          return null;
                        }),
                    Container(
                      margin: EdgeInsets.only(
                          top: 4), // Optional margin for spacing
                      height: 2, // Height of the divider
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300], // Color of the divider
                    ),
                    SizedBox(height: 16),

                    // Description TextField
                    TextFormField(
                      cursorColor:
                          Theme.of(context).brightness == Brightness.dark
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
                                String currentText =
                                    _descriptionController.text;

                                int currentHashtagCount =
                                    '#'.allMatches(currentText).length;

                                if (currentHashtagCount < 5) {
                                  if (currentText.isNotEmpty) {
                                    _descriptionController.text =
                                        '$currentText #$tag';
                                  } else {
                                    _descriptionController.text = '#$tag';
                                  }

                                  _descriptionController.selection =
                                      TextSelection.fromPosition(
                                    TextPosition(
                                        offset:
                                            _descriptionController.text.length),
                                  );

                                  setState(() {
                                    _tags.remove(
                                        tag); // Remove the selected tag from the list
                                  });
                                } else {
                                  // Show a warning message
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'You can only use up to 5 hashtags.',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      duration: Duration(seconds: 2),
                                      backgroundColor: const Color.fromARGB(
                                          255, 159, 118, 249),
                                    ),
                                  );
                                }
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
                      margin: EdgeInsets.only(
                          top: 4), // Optional margin for spacing
                      height: 2, // Height of the divider
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.grey[800]
                          : Colors.grey[300], // Color of the divider
                    ),

                    // Location
                    Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 14),
                      child: GestureDetector(
                        onTap: () async {
                          final location = await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => SelectLocationPage()),
                          );

                          if (location != null) {
                            setState(() {
                              selectedLocation =
                                  location; // Update the selected location
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined, // Location icon
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
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
                            Expanded(
                              child: Text(
                                '${selectedLocation.isNotEmpty ? selectedLocation : ''}', // The text
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey[500],
                                ),
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios, // Right arrow icon
                              size: 18,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[800]
                                  : Colors.black, // Color of the arrow
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Preview Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Navigate to the Preview Post and pass data
                          _goToNextPage();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 159, 118, 249),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              vertical: 12.0, horizontal: 24.0),
                        ),
                        child: Text('Next', style: TextStyle(fontSize: 16)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
