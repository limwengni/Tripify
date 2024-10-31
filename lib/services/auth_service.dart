import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user;
  String? _username; // New variable to hold username

  String? get username => _username; // Getter for username

  bool get isLoggedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      if (_user != null) {
        fetchUserDetails(); // Fetch user details only if user is logged in
      }
      // notifyListeners(); // Notify listeners when auth state changes
    });
  }

  Future<String?> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;
      return 'Success'; // Return a success message
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication exceptions
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      } else {
        return e.message; // Return any other error message
      }
    } catch (e) {
      // Handle any other exceptions
      return e.toString(); // Return the error message as a string
    }
  }

  Future<void> register(String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      // Fetch user details after registration if needed
    } catch (e) {
      print("Registration failed: $e");
      throw e; // Rethrow error if necessary
    }
  }

  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut(); // Directly sign out from Firebase
      _username = null; // Clear username on logout
      // notifyListeners(); // Notify listeners about the state change
    } catch (e) {
      // Handle any errors that occur during sign out
      print('Logout error: $e');
    }
  }

  Future<String> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return 'Success';
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'No user found for this email.'; 
      } else if (e.code == 'invalid-email') {
        return 'The email address is not valid.';
      } else {
        return 'Failed to send reset link, please try again later.';
      }
    } catch (e) {
      // General error handling
      return 'An unknown error occurred.';
    }
  }

  Future<void> fetchUserDetails() async {
    try {
      String uid = _user!.uid; // Using _user directly since it's not null
      DocumentSnapshot userDoc =
          await FirebaseFirestore.instance.collection('User').doc(uid).get();

      if (userDoc.exists) {
        var userData = userDoc.data() as Map<String, dynamic>?;

        if (userData != null) {
          _username = userData['username']; // Store username in the state
        } else {
          print("User data is null!");
        }
      } else {
        print("User document does not exist!");
      }
      // notifyListeners(); // Notify listeners when user details are fetched
    } catch (e) {
      print("Failed to fetch user details: $e");
      throw e; // Rethrow error if necessary
    }
  }

  // Getter for user state
  User? get user => _auth.currentUser;

  // Stream for user state changes
  Stream<User?> get userStream => _auth.authStateChanges();
}
