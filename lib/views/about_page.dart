import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class AboutPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text("About Tripify"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Goes back to the previous screen
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Welcome Section
            ExpansionTile(
              title: Text("Welcome to Tripify!",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Tripify is your ultimate travel companion, helping you plan, organize, and share your travel itineraries effortlessly.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Mission Section
            ExpansionTile(
              title: Text("Our Mission",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Tripify aims to simplify travel planning by offering an intuitive way to organize and share travel itineraries.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Version Information Section
            ExpansionTile(
              title: Text("Version Information",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Version 1.0.0 (Beta)\n"
                    "Thank you for testing our beta version! Your feedback will help shape the future of Tripify. Stay tuned for exciting updates and new features!",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Privacy Policy Section
            ExpansionTile(
              title: Text("Privacy Policy",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "We value your privacy and are committed to protecting your data. Tripify collects necessary information, such as your email address and itinerary details, to enhance your travel planning experience. "
                    "\n\nYour data is used to improve our features and communicate important updates. We do not sell your information and may share it only with trusted service providers to help operate the app. "
                    "\n\nWe take reasonable measures to protect your personal information from unauthorized access. You have the right to request access to, correction of, or deletion of your data. "
                    "\n\nFor inquiries, please contact us at support@tripify.com. For more details, you can refer to our full privacy policy.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Feedback Section
            ExpansionTile(
              title: Text("We Value Your Feedback",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "Please share your feedback with us at support@tripify.com or through the app’s feedback section.",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),

            // Contact Us Section
            ExpansionTile(
              title: Text("Contact Us",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "For support or inquiries, reach us at support@tripify.com",
                    style: TextStyle(fontSize: 16.0),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
