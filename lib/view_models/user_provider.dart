import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  UserModel? _userModel;
  bool isLoading = true;

  User? get user => _auth.currentUser;
  UserModel? get userModel => _userModel;

  UserProvider(this._userModel);

  Future<void> fetchUserDetails(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          _userModel = UserModel.fromMap(userData, uid);

          // Fetch the profile image URL after getting user details
          String profilePicUrl = await fetchProfileImageUrl();

          _profilePicUrl = profilePicUrl;

          notifyListeners();
        } else {
          print("User data is null!");
          _userModel = null;
        }
      } else {
        print("User document does not exist!");
        _userModel = null;
      }
    } catch (e) {
      print("Failed to fetch user details: $e");
      throw e; // Rethrow error if necessary
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String?> fetchUsername(String uid) async {
    isLoading = true;
    notifyListeners();

    try {
      // Fetch the document from the User collection using the provided UID
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null && userData.containsKey('username')) {
          // Fetch the username directly from the user data
          String username = userData['username'];

          notifyListeners();
          return username; // Return the username
        } else {
          print("Username field is not available in the user data.");
          return null;
        }
      } else {
        print("User document does not exist!");
        return null;
      }
    } catch (e) {
      print("Failed to fetch username: $e");
      throw e; // Rethrow error if necessary
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> fetchProfileImageUrl() async {
    if (_userModel?.profilePic != null && _userModel!.profilePic.isNotEmpty) {
      return _userModel!.profilePic;
    } else {
      return "https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251";
    }
  }

  // Future<String> fetchProfileImageUrl() async {
  //   String returnUrl = "";
  //   if (_userModel?.profilePic != null && _userModel!.profilePic.isNotEmpty) {
  //     try {
  //       final storageRef = FirebaseStorage.instance
  //           .ref('${_userModel!.uid}/pfp/${_userModel!.profilePic}');

  //       final url = await storageRef.getDownloadURL();
  //       returnUrl = url;
  //     } catch (e) {
  //       print('Error fetching profile image URL: $e');
  //       returnUrl =
  //           "https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251";
  //       // return 'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251';
  //     }
  //   }
  //   return returnUrl;
  // }

  Future<void> updateUserDetails({
    required String userId,
    String? username,
    String? bio,
    String? newProfilePicPath,
  }) async {
    final userRef = FirebaseFirestore.instance.collection('User').doc(userId);

    try {
      // Check if got new pfp
      if (newProfilePicPath != null && newProfilePicPath.isNotEmpty) {
        // Delete old pfp from firebase storage
        if (_userModel!.profilePic.isNotEmpty) {
          try {
            final oldProfilePicPath = Uri.decodeFull(_userModel!.profilePic)
                .split('o/')[1]
                .split('?')[0]; // Get the old profile pic first

            // Reference the file to delete it
            final oldProfilePicRef =
                FirebaseStorage.instance.ref().child(oldProfilePicPath);

            // Delete the file
            await oldProfilePicRef.delete();
          } catch (e) {
            print('Error deleting old profile picture: $e');
          }
        }

        // Upload the new profile picture
        final newFileName =
            newProfilePicPath.split('/').last; // Extract file name
        final newProfilePicRef =
            FirebaseStorage.instance.ref().child('${userId}/pfp/$newFileName');

        // Upload the new profile picture to Firebase Storage
        try {
          await newProfilePicRef.putFile(File(newProfilePicPath));

          final downloadUrl = await newProfilePicRef.getDownloadURL();

          _userModel?.profilePic = downloadUrl;

          updateProfilePic(downloadUrl);

          await userRef.update({'profile_picture': downloadUrl});
        } catch (e) {
          print('Error uploading new profile picture: $e');
          throw e;
        }
      }

      // Update username
      if (username != null &&
          username.isNotEmpty &&
          username != _userModel?.username) {
        _userModel?.username = username;
        await userRef.update({'username': username});
      }

      // Update the bio if it’s changed
      if (bio != null && bio.isNotEmpty && bio != _userModel?.bio) {
        _userModel?.bio = bio;
        await userRef.update({'bio': bio});
      }

      // Get the current DateTime
      DateTime dateTime = DateTime.now();
      Timestamp timestamp = Timestamp.fromDate(dateTime);

      // Update the updatedAt timestamp to the current time
      await userRef.update({
        'updated_at': timestamp, // Set the updatedAt field
      });

      notifyListeners(); // Notify listeners about the change
    } catch (error) {
      print('Error updating user details: $error');
      throw error; // Rethrow the error or handle it as needed
    }
  }

  String _profilePicUrl = ''; // Hold the profile image URL

  String get profilePicUrl => _profilePicUrl;

  void updateProfilePic(String newUrl) {
    _profilePicUrl = newUrl;
    notifyListeners(); // Notify listeners to refresh UI
  }
}
