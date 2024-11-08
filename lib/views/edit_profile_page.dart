import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/view_models/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  late Future<String> _profileImageUrl;
  String? _newProfilePicPath;
  final int _maxBioLength = 100;

  @override
  void initState() {
    super.initState();
    _profileImageUrl = Future.value('');
    _fetchUserData();

    // Add listener to the controller to track changes
    _bioController.addListener(() {
      // If the bio exceeds the maximum length, we trim it
      if (_bioController.text.length > _maxBioLength) {
        _bioController.text = _bioController.text.substring(0, _maxBioLength);
        // Move the cursor to the end of the text
        _bioController.selection = TextSelection.fromPosition(
            TextPosition(offset: _bioController.text.length));
      }
      setState(() {}); // Trigger a rebuild to show the character count
    });
  }

  Future<void> _fetchUserData() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      await userProvider.fetchUserDetails(user.uid);
      setState(() {
        _usernameController.text = userProvider.userModel?.username ?? '';

        String bioFromFirebase = userProvider.userModel?.bio ?? '';
        _bioController.text = bioFromFirebase.replaceAll(r'\n', '\n');
        
        _profileImageUrl = userProvider.fetchProfileImageUrl();
      });
    }
  }

  // This would be the function to update the profile picture
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _newProfilePicPath =
            pickedFile.path; // Store the path for the new profile picture
        _profileImageUrl = Future.value(
            _newProfilePicPath); // Store as future for the profile image URL
      });
    } else {
      setState(() {
        _newProfilePicPath = null;
        _profileImageUrl = Future.value('');
      });
    }
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final resolvedProfileImageUrl = _newProfilePicPath?.isNotEmpty == true
          ? await _profileImageUrl
          : null;

      String bioWithEscapedNewlines = _bioController.text.replaceAll('\n', '\\n');
      final trimmedBio = bioWithEscapedNewlines.trim();

      userProvider.updateUserDetails(
        userId: user.uid,
        username: _usernameController.text,
        bio: trimmedBio,
        newProfilePicPath: resolvedProfileImageUrl,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully!')),
      );
      Navigator.pop(context, true);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              GestureDetector(
                onTap: _pickImage,
                child: FutureBuilder<String>(
                  future: _profileImageUrl,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade300,
                        highlightColor: Colors.grey.shade100,
                        child: CircleAvatar(
                          radius: 65,
                          backgroundColor: Colors.grey.shade200,
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return CircleAvatar(
                        radius: 65,
                        backgroundColor: Colors.grey.shade200,
                        child: Icon(Icons.error),
                      );
                    } else {
                      return CircleAvatar(
                        radius: 65,
                        backgroundImage: _newProfilePicPath != null &&
                                _newProfilePicPath!.isNotEmpty
                            ? FileImage(File(
                                _newProfilePicPath!)) // Display the local file if available
                            : (snapshot.data != null &&
                                        snapshot.data!.isNotEmpty
                                    ? CachedNetworkImageProvider(snapshot.data!)
                                    : AssetImage(
                                        'assets/default_profile.png') // Network image
                                ) as ImageProvider,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(Icons.camera_alt, size: 18),
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Username Field
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(), // Default border color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Bio Field
              TextFormField(
                controller: _bioController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Bio',
                  border: OutlineInputBorder(),
                ),
              ),
              // Remaining characters display
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  '${_maxBioLength - _bioController.text.length} characters remaining',
                  style: TextStyle(
                    color: _bioController.text.length > _maxBioLength
                        ? Colors.red
                        : Colors.grey,
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Save Button
              ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                ),
                child: Text('Save Changes', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
