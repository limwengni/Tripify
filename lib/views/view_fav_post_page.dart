import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tripify/view_models/post_provider.dart';
import 'package:tripify/view_models/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_thumbnail_video/video_thumbnail.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/views/post_detail_page.dart';

class ViewFavouriteTravelPage extends StatefulWidget {
  const ViewFavouriteTravelPage({super.key});

  @override
  _ViewFavouriteTravelPageState createState() =>
      _ViewFavouriteTravelPageState();
}

class _ViewFavouriteTravelPageState extends State<ViewFavouriteTravelPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Favourite Travel Items"),
          bottom: const TabBar(
            tabs: [
              Tab(text: "Travel Posts"),
              Tab(text: "Travel Packages"),
            ],
            indicatorWeight: 3.0,
          ),
        ),
        body: const TabBarView(
          children: [
            FavouriteTravelPosts(),
            FavouriteTravelPackages(),
          ],
        ),
      ),
    );
  }
}

// Favourite Travel Posts
class FavouriteTravelPosts extends StatefulWidget {
  const FavouriteTravelPosts({super.key});

  @override
  _FavouriteTravelPostsState createState() => _FavouriteTravelPostsState();
}

class _FavouriteTravelPostsState extends State<FavouriteTravelPosts> {
  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }
  
  @override
  Widget build(BuildContext context) {
    final postProvider = Provider.of<PostProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.white,
        backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildPostGrid(postProvider),
          ],
        ),
      ),
    );
  }

  // Refresh data when the user pulls down to refresh
  Future<void> _refreshData() async {
    await _fetchUserData();
    setState(() {});
  }

  Future<void> _fetchUserData() async {
    final postProvider = Provider.of<PostProvider>(context, listen: false);
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        final postsWithIds = await postProvider.fetchSavedPostsForUser(userId);
        postProvider.setSavedPosts(postsWithIds);

        for (var postEntry in postsWithIds) {
          print('Doc ID: ${postEntry['id']}');
          final post = postEntry['post'] as Post;
          print('Post Title: ${post.title}');
        }
      } catch (e) {
        print("Error fetching posts for user: $e");
      }
    }
  }

  // Create a shimmer effect for each post
  Widget _buildPostShimmer() {
    Color cardColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF333333)
        : Colors.white;

    return Padding(
      padding: EdgeInsets.all(5),
      child: Card(
        semanticContainer: true,
        color: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Image Shimmer (same size as the actual image)
            Shimmer.fromColors(
              baseColor: Colors.grey.shade300,
              highlightColor: Colors.grey.shade100,
              child: Container(
                height: 150.0, // Adjust height to match actual image size
                width: double.infinity,
                color: Colors.grey.shade300,
              ),
            ),
            // Text section with shimmer
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title Shimmer
                  Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: Container(
                      height: 16.0, // Adjust width to match actual title length
                      width: 100.0, // Placeholder width for title
                      color: Colors.grey.shade300,
                    ),
                  ),
                  SizedBox(
                      height: 4.0), // Adds space between title and like section

                  // Likes Section Shimmer (Right aligned)
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align to the right
                    children: [
                      // Like icon shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Icon(
                          Icons.favorite_outline,
                          color: Colors.grey.shade300,
                          size: 16.0,
                        ),
                      ),
                      SizedBox(width: 4.0),
                      // Like count shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: Container(
                          height: 12.0,
                          width:
                              40.0, // Adjust width for like count placeholder
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Grid for displaying post shimmers
  Widget _buildPostShimmerGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: 10, // Show 10 placeholders
      itemBuilder: (context, index) {
        return _buildPostShimmer(); // Display shimmer placeholders
      },
    );
  }

  // Display shimmer grid until posts are loaded
  Widget _buildPostGrid(PostProvider postProvider) {
    if (postProvider.isLoading) {
      return _buildPostShimmerGrid();
    }

    List<Post> userPosts = postProvider.savePosts;
    List<String> postIds = postProvider.savePostsId;

    if (userPosts.isEmpty) {
      // Show a message if no posts are available
      return Center(child: Text('No posts available'));
    }

    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
          ),
          itemCount: userPosts.length,
          itemBuilder: (context, index) {
            final post = userPosts[index];
            final postId = postIds[index];
            return _buildPostUi(post, postId);
          },
        ),
        SizedBox(height: 40),
      ],
    );
  }

  // Build Post UI
  Widget _buildPostUi(Post post, String postId) {
    Color cardColor = Theme.of(context).brightness == Brightness.dark
        ? Color(0xFF333333)
        : Colors.white;

    return Padding(
      padding: EdgeInsets.all(5),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PostDetailPage(post: post, id: postId),
            ),
          );
        },
        child: Card(
          semanticContainer: true,
          color: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: post.media.isNotEmpty
                    ? Stack(children: [
                        FutureBuilder<String>(
                          future: generateThumbnail(post.media[0]),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.done &&
                                snapshot.hasData) {
                              return Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Image.file(
                                      File(snapshot.data!),
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: Colors.grey[800],
                                      child: Icon(
                                        Icons.play_arrow,
                                        size: 35,
                                        color: Colors.white,
                                      ),
                                    )
                                  ]);
                            } else if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return Shimmer.fromColors(
                                baseColor: Colors.grey[300]!,
                                highlightColor: Colors.grey[100]!,
                                child: Container(
                                  color: Colors.white,
                                  width: double.infinity,
                                ),
                              );
                            } else {
                              return CachedNetworkImage(
                                imageUrl: post.media[0],
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[100]!,
                                  child: Container(
                                    color: Colors.white,
                                    width: double.infinity,
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.cover,
                              );
                            }
                          },
                        )
                      ])
                    : Container(
                        color: Colors.grey[200],
                        width: double.infinity,
                        height: double.infinity,
                        child: Icon(Icons.image_not_supported),
                      ),
              ),
              Padding(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.title,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.favorite_outline,
                          size: 16.0,
                        ),
                        SizedBox(width: 4.0),
                        Text(
                          "${post.likesCount}",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> generateThumbnail(String videoUrl) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final response = await http.get(Uri.parse(videoUrl));

      if (response.statusCode == 200) {
        final videoFile = File('${tempDir.path}/video.mp4');
        await videoFile.writeAsBytes(response.bodyBytes);

        final XFile? thumbnail = await VideoThumbnail.thumbnailFile(
          video: videoFile.path,
          thumbnailPath: tempDir.path,
          maxWidth: 100,
          quality: 75,
        );

        if (thumbnail != null) {
          return thumbnail.path; // Return the path to the thumbnail
        } else {
          throw Exception("Failed to generate thumbnail.");
        }
      } else {
        throw Exception("Failed to load video for thumbnail");
      }
    } catch (e) {
      throw Exception("Error generating video thumbnail: $e");
    }
  }
}

// Favourite Travel Packages
class FavouriteTravelPackages extends StatefulWidget {
  const FavouriteTravelPackages({super.key});

  @override
  _FavouriteTravelPackagesState createState() =>
      _FavouriteTravelPackagesState();
}

class _FavouriteTravelPackagesState extends State<FavouriteTravelPackages> {
  bool _isLoading = true;

  // Example data for Travel Packages
  final List<Map<String, String>> travelPackages = [
    {
      "title": "Luxury Maldives Getaway",
      "subtitle": "5 nights at a top resort.",
      "image": "assets/maldives_getaway.jpg",
    },
    {
      "title": "Adventure in New Zealand",
      "subtitle": "10 days of adventure sports and sightseeing.",
      "image": "assets/new_zealand.jpg",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Simulate loading delay before showing the list
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator() // Show loading indicator
            : _buildListView(
                travelPackages), // Show travel packages after loading
      ),
    );
  }

  // Build ListView for Travel Packages
  Widget _buildListView(List<Map<String, String>> travelPackages) {
    return ListView.builder(
      itemCount: travelPackages.length,
      itemBuilder: (context, index) {
        final package = travelPackages[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(10.0),
            leading: Image.asset(package["image"]!,
                width: 60, height: 60, fit: BoxFit.cover),
            title: Text(package["title"]!),
            subtitle: Text(package["subtitle"]!),
            trailing: Icon(Icons.arrow_forward_ios),
          ),
        );
      },
    );
  }
}
