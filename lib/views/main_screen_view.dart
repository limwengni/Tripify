import 'package:flutter/material.dart';
import 'package:tripify/views/home_view.dart';
import 'package:tripify/views/itinerary_view.dart';
import 'package:tripify/views/marketplace_view.dart';
import 'package:tripify/views/request_view.dart';
import 'package:tripify/views/profile_view.dart';

class MainScreenView extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreenView> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomeView(),
    MarketplaceView(),
    ItineraryView(),
    RequestView(),
    ProfileView(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Access the theme colors
    final selectedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final unselectedColor = Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 24,
        selectedFontSize: 12.0,
        unselectedFontSize: 12.0,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.home : Icons.home_outlined,
              color: _currentIndex == 0 ? selectedColor : unselectedColor,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              color: _currentIndex == 1 ? selectedColor : unselectedColor,
            ),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.map : Icons.map_outlined,
              color: _currentIndex == 2 ? selectedColor : unselectedColor,
            ),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 3 ? Icons.local_taxi : Icons.local_taxi_rounded,
              color: _currentIndex == 3 ? selectedColor : unselectedColor,
            ),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 4 ? Icons.person : Icons.person_outline,
              color: _currentIndex == 4 ? selectedColor : unselectedColor,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        selectedItemColor: selectedColor,
        unselectedItemColor: unselectedColor,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
