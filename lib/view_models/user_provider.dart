import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Ensure you import Firestore
import 'package:tripify/models/user_model.dart';

class UserProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;

  UserModel? _userModel;

  User? get user => _auth.currentUser;
  UserModel? get userModel => _userModel;

  UserProvider(this._userModel);

  Future<void> fetchUserDetails(String uid) async {
    try {
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          String _ssm = userData['SSM'] ?? '';
          String _bio = userData['bio'] ?? 'No bio available.';
          DateTime _birthdate = (userData['birthdate'] as Timestamp).toDate();
          DateTime _createdAt = (userData['created_at'] as Timestamp).toDate();
          String _profilePic = userData['profile_picture'];
          DateTime? _updatedAt =
              (userData['updated_at'] as Timestamp?)?.toDate();
          String _username = userData['username'] ?? 'Unknown User';
          String _uid = uid;

          _userModel = UserModel(
            username: _username,
            ssm: _ssm,
            bio: _bio,
            profilePic: _profilePic,
            birthdate: _birthdate,
            createdAt: _createdAt,
            updatedAt: _updatedAt,
            uid: _uid,
          );

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
    }
  }
}
