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
import 'package:tripify/models/hashtag_model.dart';
import 'package:tripify/view_models/hashtag_provider.dart';
import 'package:tripify/view_models/post_provider.dart';

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
  TextEditingController _pollQuestionController = TextEditingController();
  List<TextEditingController> _pollOptionControllers = [
    TextEditingController(text: 'Yes'),
    TextEditingController(text: 'No'),
  ];
  List<String> _pollOptions = ['Yes', 'No'];

  late Map<File, ValueNotifier<File?>> thumbnailCache;

  String selectedLocation = '';

  List<String> _tags = [];

  final int _maxTitleLength = 20;
  int hashtagCount = 0;
  bool _isListenerEnabled = true;
  bool isPollSectionVisible = false;

  final HashtagProvider _hashtagProvider = HashtagProvider();

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

    _loadHashtags();

    for (int i = 0; i < _pollOptionControllers.length; i++) {
      _pollOptionControllers[i].addListener(() {
        setState(() {
          // Update the corresponding option in the list
          _pollOptions[i] = _pollOptionControllers[i].text;
        });
      });
    }
  }

  Future<void> _loadHashtags() async {
    try {
      List<Hashtag> hashtags = await _hashtagProvider.getHashtags();
      setState(() {
        // Store the hashtags in the _tags list
        _tags = hashtags.map((hashtag) => hashtag.name).toList();
      });
    } catch (e) {
      print("Error loading hashtags: $e");
    }
  }

  void _checkHashtagLimit(String text) {
    // Count the occurrences of `#`
    int count = '#'.allMatches(text).length;

    setState(() {
      hashtagCount = count;

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
            backgroundColor: Colors.red,
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
      final thumbnail = await genThumbnailFile(file.path);
      thumbnailCache[file]?.value = thumbnail;
    } catch (e) {
      print("Error generating thumbnail: $e");
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

  void _goToNextPage() {
    if (_formKey.currentState?.validate() ?? false) {
      // Form is valid, navigate to the next page
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PostFormPage(
            title: _titleController.text,
            description: _descriptionController.text,
            imagesWithIndex: widget.imagesWithIndex,
            location: selectedLocation,
            pollQuestion: _pollQuestionController.text,
            pollOptions: _pollOptions,
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
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    for (var controller in _pollOptionControllers) {
      controller.dispose();
    }
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
                                          valueListenable:
                                              thumbnailCache[file]!,
                                          builder: (context, thumbnail, child) {
                                            if (thumbnail != null) {
                                              return Image.file(
                                                thumbnail,
                                                width: 200,
                                                height: 200,
                                                fit: BoxFit.contain,
                                              );
                                            } else {
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
                                      backgroundColor: Colors.red,
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

                    // Poll Section
                    SizedBox(height: 16),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Create a Poll',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              if (isPollSectionVisible) {
                                _pollQuestionController.clear();
                                _pollOptions
                                    .clear(); // Clear the poll options list
                                _pollOptionControllers
                                    .clear(); // Clear the controllers list
                              }
                              if (!isPollSectionVisible) {
                                if (_pollOptions.isEmpty) {
                                  _pollOptions.add('Yes');
                                  _pollOptionControllers
                                      .add(TextEditingController(text: 'Yes'));

                                  _pollOptions.add('No');
                                  _pollOptionControllers
                                      .add(TextEditingController(text: 'No'));
                                }
                              }
                              // Toggle the visibility state
                              isPollSectionVisible = !isPollSectionVisible;
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                                vertical: 12.0, horizontal: 24.0),
                          ),
                          child:
                              Text(isPollSectionVisible ? 'Clear' : 'Create'),
                        ),
                      ],
                    ),

                    if (isPollSectionVisible)
                      Column(children: [
                        SizedBox(height: 16),

                        TextFormField(
                          cursorColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                          controller: _pollQuestionController,
                          maxLength: 40,
                          decoration: InputDecoration(
                            hintText: 'Enter your poll question here',
                            hintStyle: TextStyle(color: Colors.grey),
                            border: InputBorder.none,
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.6)
                                    : Colors.black.withOpacity(0.6),
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter a poll question';
                            }
                            return null;
                          },
                        ),

                        SizedBox(height: 16),

                        // Poll Options
                        Text(
                          'Poll Options',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                          ),
                        ),

                        // Input for each poll option
                        ...List.generate(
                          _pollOptions.length, // Generate based on list size
                          (index) => Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: _pollOptionControllers[index],
                                  decoration: InputDecoration(
                                    hintText: 'Option ${index + 1}',
                                    hintStyle: TextStyle(color: Colors.grey),
                                    border: InputBorder.none,
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors
                                                .black, // Color of the underline when focused
                                      ),
                                    ),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white.withOpacity(0.6)
                                              : Colors.black.withOpacity(0.6)),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter an option';
                                    }
                                    return null;
                                  },
                                ),
                              ),
                              if (index >= 2)
                                IconButton(
                                  icon: Icon(Icons.close,
                                      color: Colors.grey[500]),
                                  onPressed: () {
                                    setState(() {
                                      _pollOptions.removeAt(index);
                                      _pollOptionControllers.removeAt(index);
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Add Button to Add More Options
                        if (_pollOptions.length < 4)
                          ElevatedButton(
                            onPressed: () {
                              if (_pollOptions.length < 4) {
                                setState(() {
                                  _pollOptionControllers.add(TextEditingController(
                                      text:
                                          'Option ${_pollOptions.length + 1}'));
                                  _pollOptions
                                      .add('Option ${_pollOptions.length + 1}');

                                  _pollOptionControllers.last.addListener(() {
                                    setState(() {
                                      _pollOptions[_pollOptions.length - 1] =
                                          _pollOptionControllers.last.text;
                                    });
                                  });
                                });
                              } else {
                                // Show a warning message when the limit is reached
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'You can only add up to 4 poll options.',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    duration: Duration(seconds: 2),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  vertical: 12.0, horizontal: 24.0),
                            ),
                            child: Text('Add More Options'),
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
                      ]),

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
                              selectedLocation = location;
                            });
                          }
                        },
                        child: Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              size: 24,
                            ),
                            SizedBox(width: 8),
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
                            if (selectedLocation.isNotEmpty)
                              Row(
                                children: [
                                  Text(
                                    selectedLocation, // The text of the selected location
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey[500],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.close,
                                      size: 18,
                                      color: Colors.grey[500],
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        selectedLocation =
                                            ''; // Clear the selected location
                                      });
                                    },
                                  ),
                                ],
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
                    Padding(
                        padding: EdgeInsets.symmetric(horizontal: 0),
                        child: Center(
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
                              minimumSize: Size(double.infinity, 48),
                            ),
                            child: Text('Next', style: TextStyle(fontSize: 16)),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}
