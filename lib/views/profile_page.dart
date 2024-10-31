import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/view_models/user_provider.dart'; // Adjust the import based on your structure
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<String> _profileImageUrl;

  @override
  void initState() {
    super.initState();
    // Fetch user details when the profile page is initialized
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      userProvider.fetchUserDetails(user.uid);
      _profileImageUrl = userProvider.userModel!.fetchProfileImageUrl();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Access UserProvider
    final userProvider = Provider.of<UserProvider>(context);

    // Color buttonColor = Theme.of(context).brightness == Brightness.light
    //     ? const Color.fromARGB(255, 159, 118, 249) // Light theme color
    //     : Colors.white; // Dark theme color

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // First section: User details
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
              ),
              child: Row(
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
                      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                        // Handle empty URL case
                        return CircleAvatar(
                          radius: 50,
                          backgroundImage: CachedNetworkImageProvider(
                            'https://console.firebase.google.com/project/tripify-d8e12/storage/tripify-d8e12.appspot.com/files/~2Fdefaults/default.jpg',
                          ),
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
                  const SizedBox(
                      width: 16.0), // Spacing between avatar and text
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Username with optional SSM
                        Text(
                          '${userProvider.userModel?.username ?? 'Username'} ${(userProvider.userModel?.ssm)}',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(
                            height: 4.0), // Spacing between username and bio
                        // Bio
                        Text(
                          userProvider.userModel?.bio ??
                              'This user has not set a bio yet.',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                            height: 4.0), // Spacing between bio and joined date
                        // Joined date
                        Text(
                          'Joined: ${userProvider.userModel?.createdAt != null ? DateFormat('MMMM yyyy').format(userProvider.userModel!.createdAt!.toLocal()) : 'Unknown'}',
                          style:
                              const TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        const SizedBox(
                            height: 8.0), // Spacing before the button
                        // Edit Profile Button
                        ElevatedButton(
                          onPressed: () {
                            // Add your edit profile logic here
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 159, 118, 249), // Set the button color based on the theme
                            foregroundColor:
                                Colors.white, // Text color for the button
                          ),
                          child: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20.0), // Spacing between sections
            // Second section (leave it empty for now)
            const Text(
              'This is the second section. You can add more content here later.',
              style: TextStyle(fontSize: 16),
            ),
            // Add more widgets for the second section as needed
          ],
        ),
      ),
    );
  }
}
