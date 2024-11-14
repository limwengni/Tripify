import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/view_models/firestore_service.dart';
import '../theme_notifier.dart';

class ThemeSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = themeNotifier.themeMode == ThemeMode.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Theme"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start, // Align items to the start
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  vertical: 10.0,
                  horizontal: 16.0), // Adjust padding for a more compact look
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Color(0xFF333333)
                    : Colors.white, // Background color based on theme
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Theme Mode: ${themeNotifier.themeMode == ThemeMode.light ? 'Light' : 'Dark'}",
                    style: TextStyle(
                        fontSize: 18.0,
                        color: isDarkMode
                            ? Colors.white
                            : Colors.black), // Text color based on theme
                  ),
                  Switch(
                    value: themeNotifier.themeMode == ThemeMode.dark,
                    activeColor: Color.fromARGB(255, 159, 118, 249),
                    onChanged: (value) {
                      // Toggle the theme
                      if (value) {
                        themeNotifier.setTheme(ThemeMode.dark);
                      } else {
                        themeNotifier.setTheme(ThemeMode.light);
                      }

                      print('New theme: ${themeNotifier.themeMode}');

                      // Get the current user's UID
                      String uid = FirebaseAuth.instance.currentUser!.uid;

                      // Save the user's theme preference to Firestore
                      final firestoreService = FirestoreService();
                      firestoreService.saveUserTheme(uid, value);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
