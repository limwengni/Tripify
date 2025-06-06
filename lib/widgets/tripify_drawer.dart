import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:tripify/views/travel_assistant_page.dart';

class TripifyDrawer extends StatelessWidget {
  final Function(int) onItemTapped;

  const TripifyDrawer({super.key, required this.onItemTapped});

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
              onItemTapped(6);
              Navigator.pop(context);
            },
          ),
             ListTile(
            title: const Text('Wallet'),
            onTap: () {
              onItemTapped(7);
              Navigator.pop(context);
            },
          
          ),
          ListTile(
            title: const Text('AI Chat'),
            onTap: () {
              onItemTapped(8);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Emergency Call'),
            onTap: () {
              onItemTapped(9);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Document Repository'),
            onTap: () {
              onItemTapped(10);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Language Translator'),
            onTap: () {
              onItemTapped(11);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Currency Exchange Calculator'),
            onTap: () {
              onItemTapped(12);
              Navigator.pop(context);
            },
          ),
          ListTile(
            title: const Text('Settings'),
            onTap: () {
              onItemTapped(13);
              Navigator.pop(context);
            },
          ),
       
                 
        ],
      ),
    );
  }
}
