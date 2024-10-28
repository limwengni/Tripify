import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/views/accommodation_requirement_view.dart';
import 'package:tripify/views/currency_exchange_page.dart';
import 'package:tripify/views/document_repository_page.dart';
import 'package:tripify/views/emergency_call_page.dart';
import 'package:tripify/views/favorites_page.dart';
import 'package:tripify/views/language_translator_page.dart';
import 'package:tripify/views/settings_page.dart';
import 'package:tripify/views/travel_assistant_page.dart';
import 'package:tripify/widgets/tripify_drawer.dart';
import 'package:tripify/widgets/tripify_navigation_bar.dart';
import 'theme_notifier.dart';
import 'theme.dart';
import 'package:tripify/views/home_page.dart';
import 'package:tripify/views/itinerary_page.dart';
import 'package:tripify/views/marketplace_page.dart';
import 'package:tripify/views/request_page.dart';
import 'package:tripify/views/profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
  String _title = 'Home';

  List<Map<String, dynamic>> widgetItems = [
    {
      'title': 'Home',
      'widget': HomePage(),
    },
    {
      'title': 'Market',
      'widget': MarketplacePage(),
    },
    {
      'title': 'Itinerary',
      'widget': ItineraryPage(),
    },
    {
      'title': 'Request',
      'widget': AccommodationRequirementView(),
    },
     {
      'title': 'Profile',
      'widget': ProfilePage(),
    },
    {
      'title': 'AI Chat',
      'widget': TravelAssistantPage(),
    },
    {
      'title': 'Emergency Call',
      'widget': const EmergencyCallPage(),
    },
    {
      'title': 'Favorites',
      'widget': const FavoritesPage(),
    },
    {
      'title': 'Document Repository',
      'widget': const DocumentRepositoryPage(),
    },
    {
      'title': 'Language Translator',
      'widget': const LanguageTranslatorPage(),
    },
    {
      'title': 'Currency Exchange Calculator',
      'widget': const CurrencyExchangePage(),
    },
     {
      'title': 'Setting',
      'widget': SettingsPage(),
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Travis - Travel Assistant',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: Scaffold(
            appBar: AppBar(
              title: Text(_title),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 16), // Right padding only
                  child: IconButton(
                    icon: SvgPicture.asset(
                      '../assets/icons/message_icon.svg', // Path to your SVG file
                      color: isDarkMode
                          ? Colors.white
                          : Colors.black, // Optional: set color if needed
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      // Open chat messages
                    },
                  ),
                ),
              ],
            ),
            drawer: TripifyDrawer(onItemTapped: _onItemTapped),
            body: widgetItems[_currentIndex]['widget'],
            bottomNavigationBar: TripifyNavBar(
              currentIndex:  (_currentIndex < 4) ? _currentIndex : 4,
              onItemTapped: _onItemTapped,
            ),
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
