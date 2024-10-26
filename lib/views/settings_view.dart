import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_selection_view.dart';
import '../theme_notifier.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSection(
            context,
            items: [
              "Account Security",
              "Privacy Settings",
              "Notification Settings",
            ],
          ),
          SizedBox(height: 16.0),
          _buildSection(
            context,
            items: [
              "Language Settings",
              "Theme",
              "About",
            ],
          ),
          SizedBox(height: 16.0),
          _buildSection(
            context,
            items: [
              "Help Center",
              "Switch Account",
              "Log Out",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required List<String> items}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode
            ? Color(0xFF333333)
            : Colors.white, // Change background based on theme
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++)
              Column(
                children: [
                  _buildListTile(context, items[i]),
                  if (i < items.length - 1) _buildDivider(isDarkMode),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      color: isDarkMode
          ? Colors.grey[700]
          : Color(0xFFFBFBFB), // Change divider color based on theme
      height: 1,
      thickness: 2,
    );
  }

  Widget _buildListTile(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.left,
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        if (title == "Theme") {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ThemeSelectionPage()),
          ).then((selectedTheme) {
            if (selectedTheme != null) {
              final themeNotifier =
                  Provider.of<ThemeNotifier>(context, listen: false);
              themeNotifier.setTheme(
                  selectedTheme == 'light' ? ThemeMode.light : ThemeMode.dark);
            }
          });
        } else {
          // Handle other taps
        }
      },
    );
  }
}
