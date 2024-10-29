import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _username; // New variable to hold username

  User? get user => _user;
  String? get username => _username; // Getter for username

  // Stream to listen to auth state changes
  Stream<User?> get userStream => _auth.authStateChanges();

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        fetchUserDetails(); // Fetch user details only if user is logged in
      }
      notifyListeners(); // Notify listeners when auth state changes
    });
  }

  Future<void> signIn(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // User fetching handled in constructor when state changes
    } on FirebaseAuthException catch (e) {
      // Handle errors more gracefully
      print("Sign in failed: ${e.message}"); // For debugging
      throw e; // Rethrow error if necessary
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Fetch user details after registration if needed
    } catch (e) {
      print("Registration failed: $e");
      throw e; // Rethrow error if necessary
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    _username = null; // Clear username on logout
    notifyListeners();
  }

  bool get isLoggedIn => user != null;

  Future<void> fetchUserDetails() async {
    try {
      String uid = _user!.uid; // Using _user directly since it's not null
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('User').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?; 

        if (userData != null) {
          _username = userData['username']; // Store username in the state
          print("Username: $_username");
        } else {
          print("User data is null!");
        }
      } else {
        print("User document does not exist!");
      }
      notifyListeners(); // Notify listeners when user details are fetched
    } catch (e) {
      print("Failed to fetch user details: $e");
      throw e; // Rethrow error if necessary
    }
  }
}
