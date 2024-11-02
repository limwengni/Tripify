import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/models/user_model.dart';
import 'package:firebase_storage/firebase_storage.dart';

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
    if (_userModel?.profilePic != null && _userModel!.profilePic.isNotEmpty) {
      try {
        final storageRef = FirebaseStorage.instance
            .ref('${_userModel!.uid}/pfp/${_userModel!.profilePic}');

        final url = await storageRef.getDownloadURL();
        return url;
      } catch (e) {
        print('Error fetching profile image URL: $e');
        return 'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251';
      }
    }
    return 'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251';
  }

  Future<void> updateUserDetails(
    String userId, {
    required String username,
    required String bio,
    String? profileImageUrl,
  }) async {
    try {
      // Reference to the Firestore collection where user data is stored
      CollectionReference users =
          FirebaseFirestore.instance.collection('User');

      // Update user details in Firestore
      await users.doc(userId).update({
        'username': username,
        'bio': bio,
        'profileImageUrl':
            profileImageUrl ?? '', // Allowing null if not updated
      });

      // Optionally, update the userModel in the provider if needed
      userModel?.username = username;
      userModel?.bio = bio;
      userModel?.profilePic =
          profileImageUrl ?? userModel?.profilePic;

      notifyListeners(); // Notify listeners about the change
    } catch (error) {
      print('Error updating user details: $error');
      throw error; // Rethrow the error or handle it as needed
    }
  }
}
