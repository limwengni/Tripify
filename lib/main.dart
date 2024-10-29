import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'views/login_page.dart';
import 'views/accommodation_requirement_view.dart';
import 'views/currency_exchange_page.dart';
import 'views/document_repository_page.dart';
import 'views/emergency_call_page.dart';
import 'views/favorites_page.dart';
import 'views/language_translator_page.dart';
import 'views/settings_page.dart';
import 'views/travel_assistant_page.dart';
import 'views/welcome_page.dart';
import 'widgets/tripify_drawer.dart';
import 'widgets/tripify_navigation_bar.dart';

import 'theme_notifier.dart';
import 'theme.dart';
import 'views/home_page.dart';
import 'views/itinerary_page.dart';
import 'views/marketplace_page.dart';
import 'views/request_page.dart';
import 'views/profile_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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

  final List<Map<String, dynamic>> widgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {'title': 'Market', 'widget': MarketplacePage()},
    {'title': 'Itinerary', 'widget': ItineraryPage()},
    {'title': 'Request', 'widget': const AccommodationRequirementView()},
    {'title': 'Profile', 'widget': ProfilePage()},
    {'title': 'AI Chat', 'widget': TravelAssistantPage()},
    {'title': 'Emergency Call', 'widget': const EmergencyCallPage()},
    {'title': 'Favorites', 'widget': const FavoritesPage()},
    {'title': 'Document Repository', 'widget': const DocumentRepositoryPage()},
    {'title': 'Language Translator', 'widget': const LanguageTranslatorPage()},
    {'title': 'Currency Exchange Calculator', 'widget': const CurrencyExchangePage()},
    {'title': 'Settings', 'widget': SettingsPage()},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: _buildHomePage(),
        );
      },
    );
  }

  Widget _buildHomePage() {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData) {
          // User is signed in
          return Scaffold(
            appBar: AppBar(
              title: Text(_title),
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/message_icon.svg',
                      color: Theme.of(context).iconTheme.color,
                      width: 24,
                      height: 24,
                    ),
                    onPressed: () {
                      // Handle chat messages
                    },
                  ),
                ),
              ],
            ),
            drawer: TripifyDrawer(onItemTapped: _onItemTapped),
            body: widgetItems[_currentIndex]['widget'],
            bottomNavigationBar: TripifyNavBar(
              currentIndex: (_currentIndex < 4) ? _currentIndex : 4,
              onItemTapped: _onItemTapped,
            ),
          );
        } else {
          // User is not signed in, show WelcomePage
          return const WelcomePage();
        }
      },
    );
  }
}
