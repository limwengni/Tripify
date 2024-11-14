import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/views/accommodation_requirement_create_page.dart';
import 'package:tripify/views/car_rental_requirement_create_page.dart';
import 'package:tripify/views/car_rental_requirement_page.dart';
import 'package:tripify/views/chat_list_page.dart';
import 'package:tripify/views/request_selection_page.dart';
import 'package:tripify/views/test_map.dart';
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
  MainPageState createState() => MainPageState();
}

class MainPageState extends State<MainPage> {
  int _currentIndex = 0;
  int _btmNavIndex = 0;
  String _title = 'Home';

  List<Map<String, dynamic>> widgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {'title': 'Market', 'widget': MarketplacePage()},
    {'title': 'Itinerary', 'widget': ItineraryPage()},
    {'title': 'Request', 'widget': const RequestSelectionPage()},
    {
      'title': 'Accommodation Request',
      'widget': const AccommodationRequirementPage()
    },
    {'title': 'Car Rental Request', 'widget': const CarRentalRequirementPage()},
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
  List<int> navigationStack = [];

  void onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];
      if (_currentIndex > 3 && _currentIndex < 6) {
        _btmNavIndex = 3;
      } else if (_currentIndex > 5) {
        _btmNavIndex = 4;
      } else {
        _btmNavIndex = _currentIndex;
      }
      // print('Current Index: $_currentIndex'); // Debug statement
    });
  }

  Widget? floatingButtonReturn(int index) {
    if (index == 4) {
      return FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) => AccommodationRequirementCreatePage()));

          if (result != null && result is String) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
           
          }
        },
        child: const Icon(Icons.add),
      );
    }else if(index == 5){
      return FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (builder) =>CarRentalRequirementCreatePage()));

          if (result != null && result is String) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          
          }
        },
        child: const Icon(Icons.add),
      );
    }

    return null;
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
          _currentIndex =
              navigationStack.removeLast(); // Navigate to the previous page
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
            drawer: TripifyDrawer(onItemTapped: onItemTapped),
            body: widgetItems[_currentIndex]['widget'],
            bottomNavigationBar: TripifyNavBar(
              currentIndex: (_currentIndex < 4) ? _currentIndex : 4,
              onItemTapped: onItemTapped,
            ),
            floatingActionButton: floatingButtonReturn(_currentIndex)));
  }
}
