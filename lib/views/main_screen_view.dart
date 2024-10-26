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
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        iconSize: 24, // Consistent icon size
        selectedFontSize: 12.0, // Set the selected font size
        unselectedFontSize: 12.0, // Set the unselected font size
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 0 ? Icons.home : Icons.home_outlined,
              color: _currentIndex == 0 ? Colors.black : Colors.black54,
            ),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 1 ? Icons.shopping_cart : Icons.shopping_cart_outlined,
              color: _currentIndex == 1 ? Colors.black : Colors.black54,
            ),
            label: 'Marketplace',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 2 ? Icons.map : Icons.map_outlined,
              color: _currentIndex == 2 ? Colors.black : Colors.black54,
            ),
            label: 'Itinerary',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 3 ? Icons.commute : Icons.commute_rounded,
              color: _currentIndex == 3 ? Colors.black : Colors.black54,
            ),
            label: 'Request',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              _currentIndex == 4 ? Icons.person : Icons.person_outline,
              color: _currentIndex == 4 ? Colors.black : Colors.black54,
            ),
            label: 'Profile',
          ),
        ],
        currentIndex: _currentIndex,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        type: BottomNavigationBarType.fixed, // Ensures the items do not shift
      ),
    );
  }
}
