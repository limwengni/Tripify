import 'package:flutter/material.dart';
import 'package:tripify/views/accommodation_requirement_view.dart';
import 'package:tripify/widgets/tripify_drawer.dart';
import 'package:go_router/go_router.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Accommodation Requirement"),
      ),
      drawer:

        const TripifyDrawer(),
      body: const Center(
        child: Text('Home Page'),
      ),
    );
  }
}
