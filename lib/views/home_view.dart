import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme_notifier.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tripify'),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16), // Right padding only
            child: IconButton(
              icon: Icon(Icons.favorite_outline),
              onPressed: () {
                // Open chat messages
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: 16), // Right padding only
            child: IconButton(
              icon: Icon(Icons.chat_outlined),
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
