import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/views/chat_list_page.dart';
import 'package:tripify/views/travel_package_create_page.dart';
import 'package:tripify/views/verify_email_page.dart';
import 'firebase_options.dart';

import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/auth_service.dart';
import 'package:tripify/view_models/user_provider.dart';
import 'package:tripify/view_models/post_provider.dart';
import 'package:tripify/views/login_page.dart';
import 'package:tripify/views/accommodation_requirement_page.dart';
import 'package:tripify/views/currency_exchange_page.dart';
import 'package:tripify/views/document_repository_page.dart';
import 'package:tripify/views/emergency_call_page.dart';
import 'package:tripify/views/favorites_page.dart';
import 'package:tripify/views/language_translator_page.dart';
import 'package:tripify/views/settings_page.dart';
import 'package:tripify/views/travel_assistant_page.dart';
import 'package:tripify/views/welcome_page.dart';
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
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
    return;
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthService()),
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(
            create: (context) => UserProvider(UserModel(
                  username: 'Guest', // Default or placeholder values
                  role: '',
                  ssm: null,
                  bio: 'This user has not set a bio yet.',
                  profilePic:
                      'https://console.firebase.google.com/project/tripify-d8e12/storage/tripify-d8e12.appspot.com/files/~2Fdefaults/default-profile.jpg',
                  birthdate: DateTime.now(),
                  createdAt: DateTime.now(),
                  updatedAt: null,
                  uid: '',
                  likesCount: 0,
                  commentsCount: 0,
                  savedCount: 0,
                ))),
        ChangeNotifierProvider(create: (context) => PostProvider()),
      ],
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
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          // scrollBehavior: const MaterialScrollBehavior().copyWith(dragDevices: PointerDeviceKind.values.toSet()),
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              print('Snapshot data: ${snapshot.data}');

              // Debug output for tracking the authentication state
              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (snapshot.hasData) {
                // User is signed in, show the MainPage
                return VerifyEmailPage(); // Render MainPage for authenticated users
              } else {
                // User is not signed in, show WelcomePage
                return const WelcomePage();
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);
  static String id = 'main_page';

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  String _title = 'Home';

  List<Map<String, dynamic>> widgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {'title': 'Market', 'widget': MarketplacePage()},
    {'title': 'Itinerary', 'widget': ItineraryPage()},
    {'title': 'Request', 'widget': const AccommodationRequirementPage()},
    {'title': 'Profile', 'widget': ProfilePage()},
    {'title': 'AI Chat', 'widget': TravelAssistantPage()},
    {'title': 'Emergency Call', 'widget': const EmergencyCallPage()},
    {'title': 'Favorites', 'widget': const FavoritesPage()},
    {'title': 'Document Repository', 'widget': const DocumentRepositoryPage()},
    {'title': 'Language Translator', 'widget': const LanguageTranslatorPage()},
    {
      'title': 'Currency Exchange Calculator',
      'widget': const CurrencyExchangePage()
    },
    {'title': 'Settings', 'widget': SettingsPage()},
    {
      'title': 'On Shelves Travel Package',
      'widget': const TravelPackageCreatePage()
    }
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];
      // print('Current Index: $_currentIndex'); // Debug statement
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child:
                        CircularProgressIndicator()); // Centered loading spinner
              }
              if (snapshot.hasData) {
                // FirebaseAuth.instance.signOut();

                // User is signed in
                return Scaffold(
                  appBar: AppBar(
                    title: Text(_title),
                    actions: [
                      Padding(
                        padding: const EdgeInsets.only(right: 16),
                        child: IconButton(
                          icon: SvgPicture.asset(
                            'assets/icons/message_icon.svg', // Adjusted path
                            color: isDarkMode ? Colors.white : Colors.black,
                            width: 24,
                            height: 24,
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => ChatListPage()));
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
                  floatingActionButton: _currentIndex == 1
                      ? FloatingActionButton(
                          onPressed: () {
                            //do somethings
                          },
                          child: const Icon(Icons.add),
                        )
                      : null,
                );
              } else {
                // User is not signed in, redirect to login page
                return const WelcomePage();
              }
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
