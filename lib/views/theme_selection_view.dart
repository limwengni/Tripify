import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class ThemeSelectionPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Select Theme"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Add padding around the body
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
          children: [
            Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0), // Adjust padding for a more compact look
              decoration: BoxDecoration(
                color: isDarkMode ? Color(0xFF333333) : Colors.white, // Background color based on theme
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Theme Mode: ${themeNotifier.themeMode == ThemeMode.light ? 'Light' : 'Dark'}",
                    style: TextStyle(fontSize: 18.0, color: isDarkMode ? Colors.white : Colors.black), // Text color based on theme
                  ),
                  Switch(
                    value: themeNotifier.themeMode == ThemeMode.dark,
                    onChanged: (value) {
                      // Toggle the theme
                      if (value) {
                        themeNotifier.setTheme(ThemeMode.dark);
                      } else {
                        themeNotifier.setTheme(ThemeMode.light);
                      }
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
