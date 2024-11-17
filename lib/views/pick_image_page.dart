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

class PickImagesPage extends StatefulWidget {
  @override
  _PickImagesPageState createState() => _PickImagesPageState();
}

class _PickImagesPageState extends State<PickImagesPage> {
  List<AssetEntity> _assets = [];
  List<bool> _isFetched = [];
  List<File> _selectedImages = [];
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

      // Increment the page for the next request
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
    final albumId = _selectedAlbum?.id;
    if (albumId == null) return null;

    // Initialize cache for the album if not already initialized
    if (!_albumThumbnailCache.containsKey(albumId)) {
      _albumThumbnailCache[albumId] = {};
    }

    if (_albumThumbnailCache[albumId]!.containsKey(asset.id)) {
      return _albumThumbnailCache[albumId]![asset.id];
    }

    final thumbnailData = await asset.thumbnailData;
    if (thumbnailData != null) {
      _thumbnailCache[asset.id] = thumbnailData;
    }
    return thumbnailData;
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
      setState(() {
        if (_selectedImages.contains(file)) {
          _selectedImages.remove(file);
        } else {
          _selectedImages.add(file);
        }
      });
    }
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
        title: SizedBox(
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
            )),
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
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
                                          height: constraints
                                              .maxHeight, // Dynamically set height
                                          width: constraints
                                              .maxWidth, // Dynamically set width
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
                          if (_selectedImages.contains(File(asset.id)))
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.blue,
                              ),
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
                                        '${_videoDurations[asset.id]!.inMinutes.toString().padLeft(2, '0')}:${(_videoDurations[asset.id]!.inSeconds % 60).toString().padLeft(2, '0')}',
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Handle any extra actions
        child: Icon(Icons.camera_alt),
      ),
    );
  }
}
