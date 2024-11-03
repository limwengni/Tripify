import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/view_models/user_provider.dart'; // Adjust the import based on your structure
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/views/edit_profile_page.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<String> _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userProvider.fetchUserDetails(user.uid);
      _profileImageUrl = userProvider.fetchProfileImageUrl();
    }
  }

  Future<void> _refreshData() async {
    await _fetchUserData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Access UserProvider
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.white,
        backgroundColor: const Color.fromARGB(255, 159, 118, 249),
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            //User section
            _buildUserSection(userProvider),

            const SizedBox(height: 20.0),

            //Posts section
            const Text(
              'Posts',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10.0), // Spacing below title

            // Grid for displaying user posts
            // Expanded(
            //   child: FutureBuilder<List<Post>>(
            //     future: userProvider.fetchUserPosts(), // Replace with your actual method
            //     builder: (context, snapshot) {
            //       if (snapshot.connectionState == ConnectionState.waiting) {
            //         return Center(child: CircularProgressIndicator());
            //       } else if (snapshot.hasError) {
            //         return Center(child: Text('Error: ${snapshot.error}'));
            //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            //         return Center(child: Text('No posts available.'));
            //       }

            //       final posts = snapshot.data!;

            //       return GridView.builder(
            //         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            //           crossAxisCount: 2, // Two posts per row
            //           childAspectRatio: 0.75, // Adjust this for post aspect ratio
            //           crossAxisSpacing: 8.0,
            //           mainAxisSpacing: 8.0,
            //         ),
            //         itemCount: posts.length,
            //         itemBuilder: (context, index) {
            //           return _buildPostUi(posts[index]); // Pass actual post object
            //         },
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerPlaceholder() {
    return Container(
      padding: const EdgeInsets.only(top: 0.0, bottom: 16.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Row 1: Profile Picture and Username
          Row(
            children: [
              // Profile Picture Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey.shade200,
                ),
              ),
              const SizedBox(width: 16.0),
              // Username and Join Date Shimmer
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 20.0,
                        width: 150,
                        color: Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Shimmer.fromColors(
                      baseColor: Colors.grey.shade300,
                      highlightColor: Colors.grey.shade100,
                      child: Container(
                        height: 16.0,
                        width: 100,
                        color: Colors.grey.shade300,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),

          // Row 2: Bio Shimmer
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 16.0,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 8.0),
          Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 16.0,
              width: double.infinity,
              color: Colors.grey.shade300,
            ),
          ),
          const SizedBox(height: 16.0),

          // Row 3: Likes, Comments, and Saved Shimmer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildStatPlaceholder(),
                  const SizedBox(width: 16.0),
                  _buildStatPlaceholder(),
                  const SizedBox(width: 16.0),
                  _buildStatPlaceholder(),
                ],
              ),
              // Edit Profile Button Shimmer
              Shimmer.fromColors(
                baseColor: Colors.grey.shade300,
                highlightColor: Colors.grey.shade100,
                child: Container(
                  height: 40.0,
                  width: 100.0,
                  color: Colors.grey.shade300,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

// Create a shimmer effect for each stat (Likes, Comments, Saved)
  Widget _buildStatPlaceholder() {
    return Column(
      children: [
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 16.0,
            width: 40.0,
            color: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 4.0),
        Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 14.0,
            width: 30.0,
            color: Colors.grey.shade300,
          ),
        ),
      ],
    );
  }

  Widget _buildPostUi(String postId) {
    return Card(
      elevation: 2,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Example content for the post
            Image.network(
                'https://example.com/post_image/$postId'), // Replace with your image URL
            SizedBox(height: 8.0),
            Text('Post Title for $postId'),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSection(UserProvider userProvider) {
    if (userProvider.isLoading) {
      return _buildShimmerPlaceholder(); // Show shimmer while loading
    }

    return Container(
        padding: const EdgeInsets.only(top: 0.0, bottom: 16.0),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Profile Picture and Username
            Row(
              children: [
                // Profile Picture
                FutureBuilder<String>(
                  future: _profileImageUrl,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      // Handle the error case
                      return CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.error), // Error icon
                      );
                    } else {
                      // Image URL loaded successfully
                      return CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            CachedNetworkImageProvider(snapshot.data!),
                      );
                    }
                  },
                ),
                const SizedBox(width: 16.0),
                // Username and Join Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userProvider.userModel?.username ?? 'Username'} ${(userProvider.userModel?.ssm)}',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4.0),
                      Text(
                        'Joined: ${userProvider.userModel?.createdAt != null ? DateFormat('MMMM yyyy').format(userProvider.userModel!.createdAt!.toLocal()) : 'Unknown'}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16.0),

            // Row 2: Bio
            Text(
              userProvider.userModel?.bio ?? 'This user has not set a bio yet.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16.0),

            // Row 3: Likes, Comments, and Edit Profile Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Likes and Comments (Placeholder example)
                Row(
                  children: [
                    Column(
                      children: [
                        Text(
                          'Likes',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${userProvider.userModel?.likesCount}'),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      children: [
                        Text(
                          'Comments',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${userProvider.userModel?.commentsCount}'),
                      ],
                    ),
                    const SizedBox(width: 16.0),
                    Column(
                      children: [
                        Text(
                          'Saved',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('${userProvider.userModel?.savedCount}'),
                      ],
                    )
                  ],
                ),
                // Edit Profile Button
                ElevatedButton(
                  onPressed: () {
                    _navigateToEditProfile();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text(
                    'Edit Profile',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ));
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );

    // Check if the result indicates that the profile was updated
    if (result == true) {
      _fetchUserData();
    }
  }
}
