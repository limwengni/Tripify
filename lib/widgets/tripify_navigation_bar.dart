import 'package:flutter/material.dart';

class TripifyNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const TripifyNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        const Color.fromARGB(255, 159, 118,249);
    final unselectedColor =
        const Color.fromARGB(255, 159, 118,249);
 
    return BottomNavigationBar(
      iconSize: 24,
      selectedFontSize: 12.0,
      unselectedFontSize: 12.0,
      items: [
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 0 ? Icons.home : Icons.home_outlined,
            color: currentIndex == 0 ? selectedColor : unselectedColor,
          ),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 1
                ? Icons.shopping_cart
                : Icons.shopping_cart_outlined,
            color: currentIndex == 1 ? selectedColor : unselectedColor,
          ),
          label: 'Marketplace',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 2 ? Icons.map : Icons.map_outlined,
            color: currentIndex == 2 ? selectedColor : unselectedColor,
          ),
          label: 'Itinerary',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex == 3 ? Icons.local_taxi : Icons.local_taxi_outlined,
            color: currentIndex == 3 ? selectedColor : unselectedColor,
          ),
          label: 'Request',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex > 3 ? Icons.more_rounded : Icons.more_outlined,
            color: currentIndex > 3 ? selectedColor : unselectedColor,
          ),
          label: 'More',
        ),
      ],
      currentIndex: currentIndex,
      onTap: onItemTapped,
      selectedItemColor: selectedColor,
      unselectedItemColor: unselectedColor,
      type: BottomNavigationBarType.fixed,
    );
  }
}
