import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme_notifier.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Tripify'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16), // Right padding only
            child: IconButton(
              icon: Icon(Icons.favorite_outline),
              onPressed: () {
                // Open favorite action
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16), // Right padding only
            child: IconButton(
              icon: SvgPicture.asset(
                '../assets/icons/message_icon.svg', // Path to your SVG file
                color: isDarkMode ? Colors.white : Colors.black, // Optional: set color if needed
                width: 24,
                height: 24,
              ),
              onPressed: () {
                // Open chat messages
              },
            ),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Tripify!'),
      ),
    );
  }
}
