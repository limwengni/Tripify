import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tripify/views/travel_assistant_page.dart';

class TravelCompanyDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const TravelCompanyDrawer({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.blue,
            ),
            child: Text('Tripify'),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              onItemTapped(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Document Repository'),
            onTap: () {
              onItemTapped(4);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              onItemTapped(5);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Refund Applications'),
            onTap: () {
              onItemTapped(6);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
