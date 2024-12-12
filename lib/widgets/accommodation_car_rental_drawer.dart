import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tripify/views/travel_assistant_page.dart';

class AccommodationCarRentalDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const AccommodationCarRentalDrawer({super.key, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(
              color:         const Color.fromARGB(255, 159, 118,249),
            ),
            child: Text('Tripify'),
          ),
          ListTile(
            title: const Text('Profile'),
            onTap: () {
              onItemTapped(2);
              Navigator.pop(context);
            },
          ),
 
          ListTile(
            title: const Text('Document Repository'),
            onTap: () {
              onItemTapped(3);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              onItemTapped(4);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
