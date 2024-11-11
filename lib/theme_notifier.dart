import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ThemeNotifier with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light; // Default to light theme

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadTheme();
  }

  // Fetch the theme from Firebase Firestore
  Future<void> _loadTheme() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        // Check if the theme field exists and set the theme accordingly
        if (userDoc.exists) {
          String? theme = userDoc.get('theme');
          print("Theme loaded from Firestore: $theme");

          if (theme == 'dark') {
            _themeMode = ThemeMode.dark;
          } else if (theme == 'light') {
            _themeMode = ThemeMode.light;
          } else {
            _themeMode = ThemeMode
                .light; // Default to light if theme is not set correctly
          }
        }
      } catch (e) {
        print("Error loading theme: $e");
      }
    }

    notifyListeners();
  }

  // Set and save the theme in Firestore
  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();

    // Save the selected theme to Firestore
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({
          'theme': mode == ThemeMode.dark ? 'dark' : 'light',
        });
        print(
            "Theme saved to Firestore: ${mode == ThemeMode.dark ? 'dark' : 'light'}");
      } catch (e) {
        print("Error saving theme to Firestore: $e");
      }
    }
  }
}
