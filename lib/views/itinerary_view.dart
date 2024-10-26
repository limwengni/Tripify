import 'package:flutter/material.dart';

class ItineraryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Itinerary"),
      ),
      body: Center(
        child: Text("Manage Your Itineraries!"),
      ),
    );
  }
}
