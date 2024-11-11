import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
                  bio: '',
                  profilePic:
                      'https://firebasestorage.googleapis.com/v0/b/tripify-d8e12.appspot.com/o/defaults%2Fdefault.jpg?alt=media&token=8e1189e2-ea22-4bdd-952f-e9d711307251',
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
          debugShowCheckedModeBanner: false,
          home: StreamBuilder<User?>(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasData) {
                User? user = snapshot.data;
                if (user != null && user.emailVerified) {
                  return const MainPage(); // MainPage for authenticated users
                } else {
                  return VerifyEmailPage(); // VerifyEmailPage for unverified users
                }
              } else {
                return const WelcomePage(); // WelcomePage for guests
              }
            },
          ),
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
    {'title': 'Currency Exchange Calculator', 'widget': const CurrencyExchangePage()},
    {'title': 'Settings', 'widget': SettingsPage()},
    {'title': 'On Shelves Travel Package', 'widget': const TravelPackageCreatePage()}
  ];

  // Store the last visited index in a list
  List<int> navigationStack = [];
  
  void _onItemTapped(int index) {
    setState(() {
      // Store the current index to the stack before navigating
      if (_currentIndex != 0) {
        navigationStack.add(_currentIndex);
      }
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];
    });
  }

  // Pop the page if click back btn
  // Show a confirmation dialog when back button is pressed
  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      // Show confirmation dialog if user is on Home page
      bool shouldExit = await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Do you want to exit the app?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          ) ??
          false;

      return shouldExit;
    } else {
      // Pop back to the previous page if not on the Home page
      if (navigationStack.isNotEmpty) {
        setState(() {
          _currentIndex = navigationStack.removeLast(); // Navigate to the previous page
          _title = widgetItems[_currentIndex]['title'];
        });
      } else {
        // If there are no previous pages in the stack, go to the Home page
        setState(() {
          _currentIndex = 0;
          _title = widgetItems[_currentIndex]['title'];
        });
      }
      return false; // Prevent exiting the app
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text(_title),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: IconButton(
                  icon: SvgPicture.asset(
                    Provider.of<ThemeNotifier>(context).themeMode ==
                            ThemeMode.dark
                        ? 'assets/icons/message_icon_dark.svg'
                        : 'assets/icons/message_icon_light.svg',
                    width: 24,
                    height: 24,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatListPage()),
                    );
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
                    // Action for the Market page
                  },
                  child: const Icon(Icons.add),
                )
              : null,
        ));
  }
}
