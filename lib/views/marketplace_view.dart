import 'package:flutter/material.dart';

class MarketplaceView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Marketplace"),
      ),
      body: Center(
        child: Text("Explore Travel Packages!"),
      ),
    );
  }
}
