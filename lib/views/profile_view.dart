import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Profile"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {
                // Navigate to SettingsView with slide transition
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => SettingsView(),
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      const begin = Offset(1.0, 0.0); // Slide from right to left
                      const end = Offset.zero; // Slide to final position
                      const curve = Curves.easeInOut;

                      // Create the animation for the slide
                      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      // Return the slide transition
                      return SlideTransition(
                        position: offsetAnimation,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Text("Manage Your Profile"),
      ),
    );
  }
}

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: Center(
        child: Text("Settings Page"),
      ),
    );
  }
}
