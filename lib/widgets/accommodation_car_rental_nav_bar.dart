import 'package:flutter/material.dart';

class AccommodationCarRentalNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const AccommodationCarRentalNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.6);
    final unselectedColor =
        Theme.of(context).colorScheme.onSurface.withOpacity(0.6);

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
            currentIndex == 1 ? Icons.local_taxi : Icons.local_taxi_outlined,
            color: currentIndex == 1 ? selectedColor : unselectedColor,
          ),
          label: 'Request',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            currentIndex > 1 ? Icons.more_rounded : Icons.more_outlined,
            color: currentIndex > 1 ? selectedColor : unselectedColor,
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
