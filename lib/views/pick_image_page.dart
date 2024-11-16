import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart'; // For accessing gallery
import 'package:image_picker/image_picker.dart'; // For camera images
import 'package:tripify/views/add_post_page.dart'; // Your next page

class PickImagesPage extends StatefulWidget {
  @override
  _PickImagesPageState createState() => _PickImagesPageState();
}

class _PickImagesPageState extends State<PickImagesPage> {
  List<AssetEntity> _assets = []; // List of assets from the gallery
  List<File> _selectedImages = []; // List to hold selected images
  int currentPage = 0;
  int? lastPage;
  bool isMultiple = false; // Whether multiple images can be selected

  // Load images from the gallery
  Future<void> _loadImages() async {
    lastPage = currentPage;
    final permission = await PhotoManager.requestPermissionExtend();

    if (!permission.isAuth) {
      return PhotoManager.openSetting(); // Request permission
    }

    final albums = await PhotoManager.getAssetPathList(onlyAll: true);
    if (albums.isNotEmpty) {
      final assets = await albums[0].getAssetListPaged(page: currentPage, size: 100);
      setState(() {
        _assets.addAll(assets);
      });
      currentPage++;
    }
  }

  // Select or remove images from the selected list
  void _toggleImageSelection(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      setState(() {
        if (_selectedImages.contains(file)) {
          _selectedImages.remove(file); // Remove image from selection
        } else {
          _selectedImages.add(file); // Add image to selection
        }
      });
    }
  }

  // Pick an image using the camera
  Future<void> _pickImageFromCamera() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImages.add(File(pickedFile.path));
      });
    }
  }

  // Scroll handling for infinite scrolling
  void _handleScrollEvent(ScrollNotification notification) {
    if (notification.metrics.pixels / notification.metrics.maxScrollExtent <= .33) {
      return; // Don't trigger fetch if less than 33%
    }
    if (lastPage == currentPage) {
      return; // Stop if we're on the last page
    }
    _loadImages(); // Fetch more images
  }

  @override
  void initState() {
    super.initState();
    _loadImages(); // Load initial set of images
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Images'),
        leading: IconButton(
          icon: Icon(Icons.close), // Close button
          onPressed: () {
            Navigator.pop(context); // Close the page
          },
        ),
      ),
      body: NotificationListener<ScrollNotification>(
        onNotification: (scroll) {
          _handleScrollEvent(scroll);
          return true;
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];

                    return GestureDetector(
                      onTap: () {
                        _toggleImageSelection(asset); // Toggle image selection on tap
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          FutureBuilder<Uint8List?>(
                            future: asset.thumbnailData, // Fetch thumbnail data
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.waiting) {
                                return Center(child: CircularProgressIndicator());
                              }
                              if (snapshot.hasData) {
                                return Image.memory(
                                  snapshot.data!,
                                  fit: BoxFit.cover,
                                );
                              } else {
                                return Center(child: Text('No thumbnail available'));
                              }
                            },
                          ),
                          if (_selectedImages.contains(asset.file))
                            Align(
                              alignment: Alignment.topRight,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.green,
                                size: 30,
                              ),
                            ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              // Show the "Next" button only if images are selected
              if (_selectedImages.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the next page with selected images
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => NewPostPage(images: _selectedImages),
                        ),
                      );
                    },
                    child: Text('Next'),
                  ),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImageFromCamera, // Pick image from camera
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
