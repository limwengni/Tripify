import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_video_info/flutter_video_info.dart';
import 'package:tripify/views/add_post_page.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

class PickImagesPage extends StatefulWidget {
  @override
  _PickImagesPageState createState() => _PickImagesPageState();
}

class _PickImagesPageState extends State<PickImagesPage> {
  List<AssetEntity> _assets = [];
  List<bool> _isFetched = [];
  List<File> _selectedImages = [];
  Map<File, int> _selectedImagesOrder = {};
  List<AssetPathEntity> _albums = []; // List of albums on phone
  AssetPathEntity? _selectedAlbum; // Selected album
  int currentPage = 0;
  bool isMultiple = false;
  bool _isLoading = true;

  Map<String, Duration> _videoDurations = {};
  Map<String, Uint8List?> _thumbnailCache = {};
  Map<String, List<AssetEntity>> _albumAssetsCache = {};
  Map<String, Map<String, Uint8List?>> _albumThumbnailCache = {};

  final FlutterVideoInfo _videoInfo = FlutterVideoInfo();

  ValueNotifier<Map<File, int>> selectedImagesNotifier = ValueNotifier({});

  // Load albums
  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true; // Start loading
    });

    final permitted = await Permission.mediaLibrary.request().isGranted;

    if (!permitted) {
      await openAppSettings();
      setState(() {
        _isLoading = false; // Stop loading if permission is not granted
      });
      return;
    }

    // Fetch all albums
    final List<AssetPathEntity> paths = await PhotoManager.getAssetPathList();
    if (paths.isNotEmpty) {
      paths.forEach((album) {
        print('Album name: ${album.name}');
      });

      setState(() {
        _albums = paths; // Store albums
        _selectedAlbum = paths[0]; // Default to first album
      });

      // Load images from the default album
      await _loadImagesFromAlbum(paths[0]);
    } else {
      print('No albums found!');
    }

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  // Load images from a specific album
  Future<void> _loadImagesFromAlbum(AssetPathEntity album) async {
    print('Loading assets from album: ${album.name}');

    final String albumId = album.id;

    setState(() {
      _isLoading = true;
      _assets = []; // Clear current assets to prevent overlap
      _isFetched = [];
    });

    // Check cache first
    if (_albumAssetsCache.containsKey(albumId)) {
      print('Loading assets from cache for album: ${album.name}');
      setState(() {
        _assets = _albumAssetsCache[albumId]!;
        _isFetched = List.generate(_assets.length, (_) => false);
        _isLoading = false;
      });
      return;
    }

    List<AssetEntity> allAssets = [];
    int pageSize = 100; // Set page size to 100 to load in chunks
    int page = 0;
    bool hasMoreAssets = true;

    // Loop to load assets in pages
    while (hasMoreAssets && _selectedAlbum?.id == albumId) {
      final assetsPage =
          await album.getAssetListPaged(page: page, size: pageSize);

      // Filter only images and videos from the assets
      final imageAndVideoAssets = assetsPage.where((asset) {
        return asset.type == AssetType.image || asset.type == AssetType.video;
      }).toList();

      allAssets.addAll(imageAndVideoAssets);

      // If the number of assets fetched is less than the pageSize, we've reached the end
      hasMoreAssets = assetsPage.length == pageSize;

      page++;

      // If the selected album has changed, stop loading
      if (_selectedAlbum?.id != albumId) {
        print('Album changed. Stopping load for ${album.name}');
        return;
      }
    }

    // Update the cache
    _albumAssetsCache[albumId] = allAssets;

    // Update the UI with the loaded assets
    setState(() {
      _assets = allAssets;
      _isFetched = List.generate(allAssets.length, (_) => false);
      _isLoading = false;
    });

    // Fetch video durations asynchronously for videos
    final videoAssets =
        allAssets.where((asset) => asset.type == AssetType.video);

    Map<String, Duration> videoDurations = {};
    await Future.wait(videoAssets.map((asset) async {
      try {
        final file = await asset.file;
        if (file != null) {
          final info = await _videoInfo.getVideoInfo(file.path);
          if (info != null && info.duration != null) {
            videoDurations[asset.id] =
                Duration(milliseconds: info.duration!.toInt());
          }
        }
      } catch (e) {
        print('Error fetching video info: $e');
      }
    }));

    setState(() {
      _videoDurations.addAll(videoDurations);
    });

    setState(() {
      _isLoading = false; // Stop loading
    });
  }

  // Load thumbnail only once and cache it
  Future<Uint8List?> _getThumbnail(AssetEntity asset) async {
    final cacheDir = await getApplicationDocumentsDirectory();
    final albumId = _selectedAlbum?.id;
    if (albumId == null) return null;

    // Define the cache directory and file path
    final albumCacheDir = Directory('${cacheDir.path}/thumbnails/$albumId');
    final cacheFile = File('${albumCacheDir.path}/${asset.id}.thumb');

    // Ensure the cache directory exists
    if (!await albumCacheDir.exists()) {
      await albumCacheDir.create(recursive: true);
    }

    // Check if the thumbnail is cached
    if (await cacheFile.exists()) {
      print('Loaded from disk cache: ${cacheFile.path}');
      return await cacheFile.readAsBytes();
    }

    // Generate the thumbnail if not cached
    final thumbnailData = await asset.thumbnailData;
    if (thumbnailData != null) {
      await cacheFile.writeAsBytes(thumbnailData); // Save to disk
      print('Saved to disk cache: ${cacheFile.path}');
      return thumbnailData;
    }

    return null; // Return null if unable to generate thumbnail
  }

  // Handle album selection
  void _onAlbumSelected(AssetPathEntity album) {
    setState(() {
      _selectedAlbum = album;
      currentPage = 0;
    });

    _loadImagesFromAlbum(album);
  }

  // Toggle image selection
  void _toggleImageSelection(AssetEntity asset) async {
    final file = await asset.file;
    if (file != null) {
      final filePath = file.path;

      // Create a mutable copy of the map
      Map<File, int> updatedSelection = Map.from(selectedImagesNotifier.value);

      bool isSelected =
          updatedSelection.entries.any((entry) => entry.key.path == filePath);

      // bool isSelected =
      //     _selectedImages.any((selectedFile) => selectedFile.path == filePath);

      if (isSelected) {
        // If the image is already selected, remove it
        updatedSelection.removeWhere((key, value) => key.path == filePath);

        // _selectedImages
        //     .removeWhere((selectedFile) => selectedFile.path == filePath);
        // _selectedImagesOrder.removeWhere((key, value) => key.path == filePath);
      } else {
        // If the image is not selected, add it
        if (updatedSelection.length >= 9) {
          // Show a message to the user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                "You can select up to 10 images/videos only.",
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: const Color.fromARGB(255, 159, 118, 249),
            ),
          );
          return;
        }
        updatedSelection[file] = updatedSelection.length;

        // _selectedImages.add(file);
        // _selectedImagesOrder[file] = _selectedImages.length;
      }

      updatedSelection = _updateImageOrder(updatedSelection);
      selectedImagesNotifier.value = updatedSelection;
      selectedImagesNotifier.notifyListeners();

      //   // Debug print to confirm the state of the selected images and their order
      //   print(
      //       'Selected Images: ${_selectedImages.map((file) => file.path).toList()}');
      //   print(
      //       'Selected Images Order: ${_selectedImagesOrder.entries.map((entry) => "${entry.key.path}: ${entry.value}").toList()}');
    }
  }

  Map<File, int> _updateImageOrder(Map<File, int> selection) {
    int order = 1;

    // Reassign order based on the keys' current order
    for (final file in selection.keys) {
      selection[file] = order;
      debugPrint("Assigned order $order to ${file.path}");
      order++;
    }

    return selection;
  }

  Widget buildCircleAvatarForSelection(AssetEntity asset) {
    return FutureBuilder<File?>(
      future: asset.file,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return SizedBox.shrink();
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return SizedBox.shrink();
        }

        final file = snapshot.data!;

        return ValueListenableBuilder<Map<File, int>>(
          valueListenable: selectedImagesNotifier,
          builder: (context, selectedImages, _) {
            final isSelected = selectedImages.entries
                .any((entry) => entry.key.path == file.path);

            if (isSelected) {
              final order = selectedImagesNotifier.value.entries
                  .firstWhere(
                    (entry) => entry.key.path == file.path,
                  )
                  .value;

              return CircleAvatar(
                backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                radius: 14,
                child: Text(
                  '$order',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              );
            } else {
              return SizedBox
                  .shrink(); // Return an empty widget if not selected
            }
          },
        );

        // final isSelected = _selectedImagesOrder.entries.any((entry) {
        //   return entry.key.path == file.path;
        // });

        // if (isSelected) {
        //   final order = _selectedImagesOrder.entries
        //       .firstWhere((entry) => entry.key.path == file.path)
        //       .value;

        //   return CircleAvatar(
        //     backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        //     radius: 14,
        //     child: Text(
        //       '$order',
        //       style: TextStyle(
        //         color: Colors.white,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 12,
        //       ),
        //     ),
        //   );
        // } else {
        //   return SizedBox.shrink(); // Return an empty widget if not selected
        // }
      },
    );
  }

// Async function to check if the file is selected
  Future<bool> _isSelected(AssetEntity asset) async {
    for (var entry in _selectedImagesOrder.entries) {
      final assetFile = await asset.file;
      if (assetFile != null && assetFile.path == entry.key.path) {
        return true; // If the file path matches, it's selected
      }
    }
    return false; // If no match found
  }

  @override
  void initState() {
    super.initState();
    _loadAlbums();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment:
              MainAxisAlignment.spaceBetween, // Align dropdown and next button
          children: [
            SizedBox(
              width: 200,
              child: DropdownButton<AssetPathEntity>(
                value: _selectedAlbum,
                underline: SizedBox(),
                isExpanded: true,
                items: _albums.map((album) {
                  return DropdownMenuItem(
                    value: album,
                    child: Text(album.name),
                  );
                }).toList(),
                onChanged: (album) {
                  if (album != null) {
                    _onAlbumSelected(album);
                  }
                },
              ),
            ),
            // Conditionally show the "Next" button (arrow icon) only when there are selected assets
            ValueListenableBuilder<Map>(
              valueListenable: selectedImagesNotifier,
              builder: (context, selectedImages, _) {
                return selectedImages.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.arrow_forward), // "Next" arrow icon
                        onPressed: () {
                          // Action for "Next" button
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => NewPostPage(
                                imagesWithIndex: selectedImagesNotifier.value,
                              ),
                            ),
                          );
                        },
                      )
                    : SizedBox(); // Return an empty SizedBox if no images are selected
              },
            ),
          ],
        ),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: const Color.fromARGB(255, 159, 118, 249),
            ))
          : _assets.isNotEmpty
              ? GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 2,
                    mainAxisSpacing: 2,
                  ),
                  itemCount: _assets.length,
                  itemBuilder: (context, index) {
                    final asset = _assets[index];
                    final cachedThumbnail = _thumbnailCache[asset.id];

                    return GestureDetector(
                      key: ValueKey(asset.id),
                      onTap: () {
                        _toggleImageSelection(asset);
                      },
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (cachedThumbnail != null)
                            Image.memory(
                              cachedThumbnail,
                              fit: BoxFit.cover,
                            )
                          else
                            FutureBuilder<Uint8List?>(
                              key: ValueKey(asset.id),
                              future: _getThumbnail(asset),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Center(child: LayoutBuilder(
                                    builder: (context, constraints) {
                                      return Shimmer.fromColors(
                                        baseColor: Colors.grey[300]!,
                                        highlightColor: Colors.grey[100]!,
                                        child: Container(
                                          height: constraints.maxHeight,
                                          width: constraints.maxWidth,
                                          color: Colors.grey[300],
                                        ),
                                      );
                                    },
                                  ));
                                }
                                if (snapshot.hasData) {
                                  return Image.memory(
                                    snapshot.data!,
                                    fit: BoxFit.cover,
                                  );
                                } else {
                                  return Container();
                                }
                              },
                            ),

                          // Show circle avatar with number if image is selected
                          Positioned(
                            top: 8,
                            right: 8,
                            child: buildCircleAvatarForSelection(asset),
                          ),
                          if (asset.type == AssetType.video)
                            Positioned(
                              bottom: 8,
                              right: 8,
                              child: _videoDurations.containsKey(asset.id)
                                  ? Container(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      color: Colors.black.withOpacity(0.6),
                                      child: Text(
                                        '${_videoDurations[asset.id]!.inMinutes.toString().padLeft(1, '0')}:${(_videoDurations[asset.id]!.inSeconds % 60).toString().padLeft(2, '0')}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child: Container(
                                        height: 20,
                                        width: 50,
                                        color: Colors.grey[300],
                                      ),
                                    ), // Show loading while fetching duration
                            ),
                        ],
                      ),
                    );
                  },
                )
              : Center(child: Text('No images available')),
    );
  }
}
