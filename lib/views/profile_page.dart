import 'package:flutter/material.dart';
import 'package:tripify/widgets/profile_drawer.dart';
import 'package:tripify/views/settings_page.dart';

class ProfilePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          AppBar(
            title: Text("Profile"),
            leading: Builder(
              builder: (context) => IconButton(
                icon: Icon(Icons.menu), // Hamburger icon
                onPressed: () {
                  // Open the drawer using the main screen's method
                  // You can use a GlobalKey if necessary
                  Scaffold.of(context).openDrawer();
                },
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: IconButton(
                  icon: Icon(Icons.settings_outlined),
                  onPressed: () {
                    // Navigate to SettingsView with slide transition
                    Navigator.push(
                      context,
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            SettingsPage(),
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
          Expanded(
            child: Center(
              child: Text("Manage Your Profile"),
            ),
          ),
        ],
      ),
    );
  }
}
