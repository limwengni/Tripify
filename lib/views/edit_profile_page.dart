import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:tripify/view_models/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:tripify/view_models/firestore_service.dart';
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
  final int _maxBioLength = 150;
  FirestoreService firestoreService = FirestoreService();

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
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    if (pickedFile != null) {
      setState(() {
        _newProfilePicPath = pickedFile.path; // Store the local file path
        _profileImageUrl =
            Future.value(pickedFile.path); // Update with the local path
      });
    } else {
      setState(() {
        _newProfilePicPath = null;
        _profileImageUrl = Future.value(userProvider.fetchProfileImageUrl());
      });
    }
  }

  void _saveProfile() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = FirebaseAuth.instance.currentUser;

    if (_formKey.currentState?.validate() ?? false) {
      if (user != null) {
        bool isUsernameUnique = await firestoreService
            .isUsernameCorrectForUID(_usernameController.text, user.uid);

        if (!isUsernameUnique) {
          // Username is not unique, show an error message and stop the process
          showDialog(
            context: context,
            builder: (BuildContext context) {
              final bool isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              final textColor = isDarkMode ? Colors.white : Colors.black;
              final dialogBackgroundColor =
                  isDarkMode ? Color(0xFF333333) : Colors.white;

              return AlertDialog(
                backgroundColor:
                    dialogBackgroundColor, // Apply background color
                title: const Text(
                  'Error',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Text(
                  'Username is already taken. Please choose a different one.',
                  style: TextStyle(
                      color: textColor), // Content text color based on theme
                ),
                actions: <Widget>[
                  TextButton(
                    onPressed: () => Navigator.pop(context, 'OK'),
                    child: Text(
                      'OK',
                      style: TextStyle(
                          color: textColor), // Button text color based on theme
                    ),
                  ),
                ],
              );
            },
          );
          return;
        }

        String bioWithEscapedNewlines =
            _bioController.text.replaceAll('\n', '\\n');
        final trimmedBio = bioWithEscapedNewlines.trim();

        userProvider.updateUserDetails(
          userId: user.uid,
          username: _usernameController.text,
          bio: trimmedBio,
          newProfilePicPath: _newProfilePicPath,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final bool isDarkMode =
              Theme.of(context).brightness == Brightness.dark;
          final textColor = isDarkMode
              ? Colors.white
              : Colors.black; // Text color based on theme
          final dialogBackgroundColor = isDarkMode
              ? Color(0xFF333333)
              : Colors.white; // Dialog background color

          return AlertDialog(
            backgroundColor: dialogBackgroundColor, // Apply background color
            title: const Text(
              'Error',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              'Please ensure all fields are filled correctly.',
              style: TextStyle(
                  color: textColor), // Content text color based on theme
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.pop(context, 'OK'),
                child: Text(
                  'OK',
                  style: TextStyle(
                      color: textColor), // Button text color based on theme
                ),
              ),
            ],
          );
        },
      );
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
                                    : NetworkImage(
                                        'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251') // Network image
                                ) as ImageProvider,
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            radius: 18,
                            backgroundColor: Colors.grey.shade200,
                            child: Icon(Icons.camera_alt, 
                            size: 18, 
                            color: Theme.of(context).brightness == Brightness.light? Color(0xFF3B3B3B): null),
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
                cursorColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(), // Default border color
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a username';
                  }

                  if (value.length < 3) {
                    return 'Username must be at least 3 characters long';
                  }

                  if (value.length > 20) {
                    return 'Username cannot exceed 20 characters';
                  }

                  final pattern =
                      r'^[a-zA-Z0-9_]+$'; // Regex to allow alphanumeric and underscore only
                  final regExp = RegExp(pattern);
                  if (!regExp.hasMatch(value)) {
                    return 'Username can only contain letters, numbers, and underscores';
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
