import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/widgets/tripify_navigation_bar.dart';
import 'theme_notifier.dart';
import 'theme.dart';
import 'package:tripify/views/home_page.dart';
import 'package:tripify/views/itinerary_page.dart';
import 'package:tripify/views/marketplace_page.dart';
import 'package:tripify/views/request_page.dart';
import 'package:tripify/views/profile_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    HomePage(),
    MarketplacePage(),
    ItineraryPage(),
    RequestPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Travis - Travel Assistant',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: Scaffold(
            body: _screens[_currentIndex],
            bottomNavigationBar: TripifyNavBar(
              currentIndex: _currentIndex,
              onItemTapped: _onItemTapped,
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
