import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart';
import 'package:tripify/theme.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/views/login_page.dart';

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

  Future<String?> signIn(
      String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      _user = userCredential.user;

      // Fetch user theme preference from Firestore
      final FirestoreService firestoreService = FirestoreService();
      String theme = await firestoreService
          .getUserTheme(FirebaseAuth.instance.currentUser!.uid);

      final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);

      // Apply the theme based on user preference
      if (theme == 'dark') {
        themeNotifier.setTheme(ThemeMode.dark);
      } else {
        themeNotifier.setTheme(ThemeMode.light);
      }

      String accountStatus = await getAccountStatus();

      if (accountStatus == 'disabled') {
        await FirebaseAuth.instance.signOut();
        return 'Your account has been disabled. Please contact support if you believe this is a mistake.';
      } else if (accountStatus == 'error' || accountStatus == 'not_found') {
        return 'An error occurred while checking your account. Please try again later.';
      }

      return 'Success'; // Return a success message
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase authentication exceptions
      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        return 'Invalid email or password.';
      } else if (e.code == 'user-disabled') {
        return 'Your account has been disabled. Please contact support if you believe this is a mistake.';
      } else {
        return 'Unable to sign in. Please verify your credentials or contact support for assistance.';
      }
    } catch (e) {
      // Handle any other exceptions
      return e.toString(); // Return the error message as a string
    }
  }

  Future<void> signUp(String email, String password) async {
    try {
      // Create the user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print("Failed to register user: $e");
      throw e; // Rethrow error if necessary
    }
  }

  Future<void> logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut(); // Directly sign out from Firebase
      _user = null;

      // final themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
      // themeNotifier
      //     .setTheme(ThemeMode.light); // Set theme to light after logout
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

  Future<String> getAccountStatus() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Retrieve the user document from Firestore
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData =
              userDoc.data() as Map<String, dynamic>;

          return userData['status'] ?? 'active';
        } else {
          print("User document not found.");
          return 'not_found'; // Optional: Handle cases where the document doesn't exist
        }
      } else {
        return 'no_user'; // Optional: Handle cases where no user is logged in
      }
    } catch (e) {
      print("Error checking account status: $e");
      return 'error'; // Optional: Return error status for exceptions
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
