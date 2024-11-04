import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
          await fetchProfileImageUrl();

          notifyListeners();
        } else {
          print("User data is null!");
        }
      } else {
        print("User document does not exist!");
      }
    } catch (e) {
      print("Failed to fetch user details: $e");
      throw e; // Rethrow error if necessary
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<String> fetchProfileImageUrl() async {
    String returnUrl = "";
    if (_userModel?.profilePic != null && _userModel!.profilePic.isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref('${_userModel!.uid}/pfp/${_userModel!.profilePic}');

        final url = await storageRef.getDownloadURL();
        returnUrl = url;
      } catch (e) {
        print('Error fetching profile image URL: $e');
        returnUrl = "https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251";
        // return 'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251';
      }
    }
    return returnUrl;
  }

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
          final oldProfilePicRef = FirebaseStorage.instance
              .ref()
              .child('${userId}/pfp/${_userModel!.profilePic}');

          await oldProfilePicRef.delete();
        }

        // Upload the new profile picture
        final newFileName =
            newProfilePicPath.split('/').last; // Extract file name
        final newProfilePicRef =
            FirebaseStorage.instance.ref().child('${userId}/pfp/$newFileName');
        await newProfilePicRef.putFile(File(newProfilePicPath));

        // Update the user model and Firestore with the new picture filename
        _userModel?.profilePic = newFileName;
        await userRef.update({'profile_picture': newFileName});
      }

      // Update username
      if (username != null && username.isNotEmpty && username != _userModel?.username) {
        _userModel?.username = username;
        await userRef.update({'username': username});
      }

      // Update the bio if it’s changed
      if (bio != null && bio.isNotEmpty &&  bio != _userModel?.bio) {
        _userModel?.bio = bio;
        await userRef.update({'bio': bio});
      }

      notifyListeners(); // Notify listeners about the change
      
    } catch (error) {
      print('Error updating user details: $error');
      throw error; // Rethrow the error or handle it as needed
    }
  }
}
