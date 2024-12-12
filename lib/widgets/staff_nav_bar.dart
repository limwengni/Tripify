import 'package:flutter/material.dart';

class StaffNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const StaffNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final selectedColor = const Color.fromARGB(255, 159, 118, 249);
    final unselectedColor = const Color.fromARGB(255, 0, 0, 0);

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
            currentIndex == 1 ? Icons.settings : Icons.settings_outlined,
            color: currentIndex == 1 ? selectedColor : unselectedColor,
          ),
          label: 'Setting',
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
