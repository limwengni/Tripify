import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? _user; //for firebase one (like get their email add)

  bool get isLoggedIn => _user != null;

  AuthService() {
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      notifyListeners(); // Notify listeners when auth state changes
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
Future<void> signUp(String email, String password) async {
  try {
    // Create the user
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Get the current user
    // User? user = userCredential.user;

    // if (user != null) {
    //   // Send verification email
    //   await user.sendEmailVerification();
    //   print("Verification email sent to ${user.email}");
      
    //   // Optionally, sign out the user to force them to verify their email
    //   // await FirebaseAuth.instance.signOut();
    // }
  } catch (e) {
    print("Failed to register user: $e");
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
      _user = null;
      notifyListeners();
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

  Future sendVerificationEmail() async {
    final user = FirebaseAuth.instance.currentUser!;
    await user.sendEmailVerification();
  }

  // Getter for user state
  User? get user => _auth.currentUser;

  // Stream for user state changes
  Stream<User?> get userStream => _auth.authStateChanges();
}
