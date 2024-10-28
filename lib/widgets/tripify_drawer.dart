import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TripifyDrawer extends StatelessWidget {

  const TripifyDrawer({super.key});

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
            title: const Text('Home'),
            onTap: () {
                           context.go('/');
              Navigator.pop(context);

            },
          ),
          ListTile(
            title: const Text('Accommodation'),
            onTap: () {
             context.go('/accommodation');

              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
