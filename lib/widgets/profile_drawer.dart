import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tripify/views/travel_assistant_page.dart';

class ProfileDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  ProfileDrawer({required this.onItemTapped});

  // Custom divider widget
  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Divider(
        color: Colors.grey[700],
        height: 1,
        thickness: 1.5,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        width: 300,
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // User Profile Section
            Container(
              width: double.infinity, // Ensures full width
              padding: EdgeInsets.all(16),
              color: Colors.blue, // Blue background filling entire section
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('assets/images/travis.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Username',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Traveler', // User role/tagline
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Communication & Support Category
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icons/robot_icon.svg',
                  width: 20,
                  height: 20,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
                title: Text('AI Chat'),
                onTap: () {
                  TravelAssistantPage();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.local_phone),
                title: Text('Emergency Call Service'),
                onTap: () {
                  onItemTapped(6);
                },
              ),
            ),
            _buildDivider(),

            // Travel Management Category
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.bookmark),
                title: Text('Favorites'),
                onTap: () {
                  onItemTapped(1);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.file_copy),
                title: Text('Document Repository'),
                onTap: () {
                  onItemTapped(2);
                },
              ),
            ),
            _buildDivider(),

            // Language & Currency Services Category
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.translate),
                title: Text('Language Translation'),
                onTap: () {
                  onItemTapped(4);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.monetization_on),
                title: Text('Currency Exchange Calculation'),
                onTap: () {
                  onItemTapped(5);
                },
              ),
            ),
            _buildDivider(),

            // Additional Settings & Feedback
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.settings),
                title: Text('Settings'),
                onTap: () {
                  onItemTapped(7); // Add corresponding index in function if needed
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: ListTile(
                leading: Icon(Icons.feedback),
                title: Text('Feedback'),
                onTap: () {
                  onItemTapped(8); // Add corresponding index in function if needed
                },
              ),
            ),

            Spacer(),

            // Footer Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'App Version 1.0.0',
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
