import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/view_models/user_provider.dart'; // Adjust the import based on your structure
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/post_model.dart';
import 'package:tripify/views/edit_profile_page.dart';
import 'package:tripify/views/add_post_page.dart';
import 'package:tripify/views/pick_image_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/gestures.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await userProvider.fetchUserDetails(user.uid);

      // // After fetching user details, the _profileImageUrl is updated in the provider
      // setState(() {
      //   // Fetching the profile image URL directly from the provider after details are fetched
      //   _profileImageUrl = userProvider.userModel?.profilePic ??
      //       "https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251";
      // });

      // print(_profileImageUrl);
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
            _buildPostGrid(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Action when the button is pressed
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => PickImagesPage()),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
        backgroundColor:
            const Color.fromARGB(255, 159, 118, 249), // Customize color
      ),
    );
  }

  Widget _buildUserSection(UserProvider userProvider) {
    if (userProvider.isLoading) {
      return _buildShimmerPlaceholder(); // Show shimmer while loading
    }

    String userBio = userProvider.userModel?.bio ?? '';

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
                CachedNetworkImage(
                  imageUrl: userProvider.profilePicUrl, // Use your image URL
                  placeholder: (context, url) => Shimmer.fromColors(
                    baseColor: Colors.grey.shade300,
                    highlightColor: Colors.grey.shade100,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey.shade200,
                    ),
                  ),
                  errorWidget: (context, url, error) => CircleAvatar(
                    radius: 50,
                    backgroundImage: NetworkImage(
                      "https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251",
                    ), // Use the default image URL
                    backgroundColor:
                        Colors.grey.shade200, // Fallback background color
                  ),
                  imageBuilder: (context, imageProvider) => CircleAvatar(
                    radius: 50,
                    backgroundImage: imageProvider,
                  ),
                ),
                const SizedBox(width: 16.0),
                // Username and Join Date
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${userProvider.userModel?.username ?? 'Username'} ${(userProvider.userModel?.ssm ?? '')}',
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
            Container(
              alignment: Alignment.centerLeft,
              padding: EdgeInsets.zero,
              child: RichText(
                text: TextSpan(
                  style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).brightness == Brightness.light
                          ? Color(0xFF3B3B3B)
                          : Colors.white),
                  children: _buildBioTextSpans(userBio),
                ),
              ),
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

  List<TextSpan> _buildBioTextSpans(String bio) {
    // Split the bio into lines based on `\\n`
    final lines = bio.split('\\n');
    final List<TextSpan> textSpans = [];

    for (var line in lines) {
      // Split each line into words
      final words = line.split(' ');

      for (var word in words) {
        if (_isLink(word)) {
          // Prepare the link with "http://" prefix if needed
          final link = word.startsWith('http') ? word : 'http://$word';

          // Display only the domain name (remove "www." and "http://" for display)
          final displayText =
              word.replaceAll(RegExp(r'^(https?:\/\/)?(www\.)?'), '');

          textSpans.add(
            TextSpan(
              text: '$displayText ',
              style: TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse(link));
                },
            ),
          );
        } else {
          textSpans.add(TextSpan(text: '$word ')); // Regular text
        }
      }

      // Add a newline TextSpan after each line, except the last one
      if (line != lines.last) {
        textSpans.add(TextSpan(text: '\n'));
      }
    }

    return textSpans;
  }

  bool _isLink(String text) {
    // Regular expression to identify links
    final regex = RegExp(r'^(https?:\/\/|www\.)[^\s]+$', caseSensitive: false);
    return regex.hasMatch(text);
  }

  void _navigateToEditProfile() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );

    if (result == true) {
      _fetchUserData();
    }
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

// Create a shimmer effect for each posts
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
                height: 160.0, // Adjust height to match actual image size
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
                      height: 8.0), // Adds space between title and like section

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
  Widget _buildPostGrid() {
    bool isLoading = false; // Update this based on loading status

    return isLoading
        ? _buildPostShimmerGrid()
        : GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.75,
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
            ),
            itemCount: 10, // Set this number based on actual post count
            itemBuilder: (context, index) {
              return _buildPostUi(); // Display actual post UI
            },
          );
  }

// Build Post UI
  Widget _buildPostUi() {
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
            Expanded(
              child: CachedNetworkImage(
                imageUrl:
                    'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/GdkQDokljsVMIkPLanvtFdoshDR2%2Fpfp%2FUntitled732_20241115203206.png?alt=media&token=54a8e225-170c-470a-b531-807ab7c95d09', // Replace with dynamic image URL
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                    width: double.infinity,
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Text section with dynamic post title
            Padding(
              padding: EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Post Title
                  Text(
                    'This is a title', // Replace with dynamic post title
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                      height:
                          8.0), // Adds space between the title and likes section

                  // Likes Section (Right aligned)
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.end, // Align to the right
                    children: [
                      Icon(Icons.favorite_outline, size: 16.0),
                      SizedBox(width: 4.0),
                      Text(
                        '20', // Replace with dynamic like count
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
    );
  }
}
