import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/view_models/stripe_key.dart';
import 'package:tripify/view_models/hashtag_provider.dart';
import 'package:tripify/views/accommodation_requirement_create_page.dart';
import 'package:tripify/views/car_rental_requirement_create_page.dart';
import 'package:tripify/views/car_rental_requirement_page.dart';
import 'package:tripify/views/conversations_page.dart';
import 'package:tripify/views/new_travel_package_craete_page.dart';
import 'package:tripify/views/refund_page.dart';
import 'package:tripify/views/request_selection_page.dart';
import 'package:tripify/views/test_map.dart';
import 'package:tripify/views/travel_package_create_page.dart';
import 'package:tripify/views/verify_email_page.dart';
import 'package:tripify/views/wallet_page_page.dart';
import 'package:tripify/widgets/accommodation_car_rental_drawer.dart';
import 'package:tripify/widgets/accommodation_car_rental_nav_bar.dart';
import 'package:tripify/widgets/travel_company_drawer.dart';
import 'package:tripify/widgets/travel_company_nav_bar.dart';
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
    await _setup();
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
        ChangeNotifierProvider(create: (context) => HashtagProvider()),
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

Future<void> _setup() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = stripePublishableKey;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (context) => ThemeNotifier(),
        child: Consumer<ThemeNotifier>(
          builder: (context, themeNotifier, child) {
            print("Current themeMode: ${themeNotifier.themeMode}");
            print(
                "Dark theme applied: ${themeNotifier.themeMode == ThemeMode.dark}");
            return MaterialApp(
              theme: lightTheme,
              darkTheme: darkTheme,
              themeMode: themeNotifier.themeMode,
              debugShowCheckedModeBanner: false,
              home: FirebaseAuthStateHandler(),
            );
          },
        ));
  }
}

class FirebaseAuthStateHandler extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance
          .authStateChanges(), // Listen for auth state changes
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show loading spinner while waiting for Firebase auth state
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          // Show error message if there is an error
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // If the user is authenticated, we either check for email verification or just go to main
        if (snapshot.hasData) {
          // Check if the user's email is verified
          if (FirebaseAuth.instance.currentUser?.emailVerified ?? false) {
            return const MainPage(); // User is authenticated and email is verified
          } else {
            return VerifyEmailPage(); // User is authenticated but needs to verify email
          }
        } else {
          // If no user is authenticated, show the WelcomePage
          return const WelcomePage();
        }
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
  UserModel? user;

  String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  FirestoreService _firestoreService = FirestoreService();

  List<Map<String, dynamic>> widgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {'title': 'Market', 'widget': MarketplacePage()},
    {'title': 'Itinerary', 'widget': ItineraryPage()},
    {'title': 'Request', 'widget': const RequestSelectionPage()},
    {
      'title': 'Accommodation Request',
      'widget': const AccommodationRequirementCreatePage()
    },
    {
      'title': 'Car Rental Request',
      'widget': const CarRentalRequirementCreatePage()
    },
    {'title': 'Profile', 'widget': ProfilePage()},
    {'title': 'AI Chat', 'widget': TravelAssistantPage()},
    {'title': 'Emergency Call', 'widget': const EmergencyCallPage()},
    {'title': 'Document Repository', 'widget': const DocumentRepositoryPage()},
    {'title': 'Language Translator', 'widget': const LanguageTranslatorPage()},
    {
      'title': 'Currency Exchange Calculator',
      'widget': const CurrencyExchangePage()
    },
    {'title': 'Settings', 'widget': SettingsPage()},
    {
      'title': 'On Shelves Travel Package',
      'widget': const NewTravelPackageCreatePage()
    },
    {'title': 'Wallet', 'widget': WalletPage()},
  ];
  List<Map<String, dynamic>> accommodationWidgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {
      'title': 'Accommodation Request',
      'widget': const AccommodationRequirementPage()
    },
    {'title': 'Profile', 'widget': ProfilePage()},
    
    {'title': 'Document Repository', 'widget': const DocumentRepositoryPage()},
    {'title': 'Settings', 'widget': SettingsPage()},
  ];

  List<Map<String, dynamic>> carRentalWidgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {
      'title': 'Accommodation Request',
      'widget': const CarRentalRequirementPage()
    },
    {'title': 'Profile', 'widget': ProfilePage()},
    {'title': 'Document Repository', 'widget': const DocumentRepositoryPage()},
    {'title': 'Settings', 'widget': SettingsPage()},
  ];

  List<Map<String, dynamic>> travelPackageCompanyWidgetItems = [
    {'title': 'Home', 'widget': HomePage()},
    {'title': 'Marketplace', 'widget': MarketplacePage()},
    {'title': 'On Shelves Travel Package', 'widget': NewTravelPackageCreatePage()},
    {'title': 'Profile', 'widget': ProfilePage()},
    {'title': 'Document Repository', 'widget': const DocumentRepositoryPage()},
    {'title': 'Settings', 'widget': SettingsPage()},
    {'title': 'Refund Applications', 'widget':RefundPage()},
    
  ];
  List<int> navigationStack = [];

  @override
  void initState() {
    super.initState();

    getUserData();
  }

  void getUserData() async {
    Map<String, dynamic>? userMap =
        await _firestoreService.getDataById('User', currentUserId);
    if (userMap != null) {
      setState(() {
        user = UserModel.fromMap(userMap!, currentUserId);
        if (user!.role == 'Accommodation Rental Company') {
          widgetItems = accommodationWidgetItems;
        } else if (user!.role == 'Car Rental Company') {
          widgetItems = carRentalWidgetItems;
        } else if (user!.role == 'Travel Company') {
          widgetItems = travelPackageCompanyWidgetItems;
        }
      });
    }
  }

  void onItemTapped(int index) {
    setState(() {
      // Store the current index to the stack before navigating
      if (_currentIndex != 0) {
        navigationStack.add(_currentIndex);
      }

      // Set the current index and update the title
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];

      // Manage bottom navigation index based on current page
      if (_currentIndex > 3 && _currentIndex < 6) {
        _btmNavIndex = 3;
      } else if (_currentIndex > 5) {
        _btmNavIndex = 4;
      } else {
        _btmNavIndex = _currentIndex;
      }
    });
  }

  void accommodationCarRentalOnItemTapped(int index) {
    setState(() {
      // Store the current index to the stack before navigating
      if (_currentIndex != 0) {
        navigationStack.add(_currentIndex);
      }

      // Set the current index and update the title
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];

      // Manage bottom navigation index based on current page
      if (_currentIndex > 1 && _currentIndex < 6) {
        _btmNavIndex = 2;
      } else {
        _btmNavIndex = _currentIndex;
      }
    });
  }

  void travelCompanyOnItemTapped(int index) {
    setState(() {
      // Store the current index to the stack before navigating
      if (_currentIndex != 0) {
        navigationStack.add(_currentIndex);
      }

      // Set the current index and update the title
      _currentIndex = index;
      _title = widgetItems[_currentIndex]['title'];

      // Manage bottom navigation index based on current page
      if (_currentIndex > 2 && _currentIndex < 7) {
        _btmNavIndex = 3;
      } else {
        _btmNavIndex = _currentIndex;
      }
    });
  }

  // Widget? floatingButtonReturn(int index) {
  //   if (index == 4) {
  //     return FloatingActionButton(
  //       onPressed: () async {
  //         final result = await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (builder) => AccommodationRequirementCreatePage()));

  //         if (result != null && result is String) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(result),
  //               backgroundColor: Colors.green,
  //               duration: Duration(seconds: 2),
  //             ),
  //           );
  //         }
  //       },
  //       child: const Icon(Icons.add),
  //     );
  //   } else if (index == 5) {
  //     return FloatingActionButton(
  //       onPressed: () async {
  //         final result = await Navigator.push(
  //             context,
  //             MaterialPageRoute(
  //                 builder: (builder) => CarRentalRequirementCreatePage()));

  //         if (result != null && result is String) {
  //           ScaffoldMessenger.of(context).showSnackBar(
  //             SnackBar(
  //               content: Text(result),
  //               backgroundColor: Colors.green,
  //               duration: Duration(seconds: 2),
  //             ),
  //           );
  //         }
  //       },
  //       child: const Icon(Icons.add),
  //     );
  //   }

  //   return null;
  // }

  // Pop the page if click back btn
  // Show a confirmation dialog when back button is pressed
  Future<bool> _onWillPop() async {
    if (_currentIndex == 0) {
      // Show confirmation dialog if user is on Home page
      bool shouldExit = await showDialog(
            context: context,
            builder: (BuildContext context) {
              final bool isDarkMode =
                  Theme.of(context).brightness == Brightness.dark;
              final textColor = isDarkMode ? Colors.white : Colors.black;
              final dialogBackgroundColor =
                  isDarkMode ? const Color(0xFF333333) : Colors.white;

              return AlertDialog(
                backgroundColor: dialogBackgroundColor,
                title: Text(
                  'Exit App',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                content: Text(
                  'Do you want to exit the app?',
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'No',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () =>
                        Navigator.of(context).pop(true), // Exit app
                    child: Text(
                      'Yes',
                      style: TextStyle(
                        color: textColor,
                      ),
                    ),
                  ),
                ],
              );
            },
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

          if (_currentIndex > 3 && _currentIndex < 6) {
            _btmNavIndex = 3;
          } else if (_currentIndex > 5) {
            _btmNavIndex = 4;
          } else {
            _btmNavIndex = _currentIndex;
          }
        });
      } else {
        // If there are no previous pages in the stack, go to the Home page
        setState(() {
          _currentIndex = 0;
          _btmNavIndex = 0;
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
                  color: const Color.fromARGB(255, 159, 118, 249),
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
        drawer: user != null ? _buildDrawerBasedOnRole(user!.role) : null,
        body: widgetItems[_currentIndex]['widget'],
        bottomNavigationBar:
            user != null ? _buildNavBarBasedOnRole(user!.role) : null,
        // floatingActionButton: floatingButtonReturn(_currentIndex),
      ),
    );
  }

// Method to return the correct NavBar based on user role
  Widget _buildNavBarBasedOnRole(String role) {
    switch (role) {
      case 'Normal User':
        return TripifyNavBar(
          currentIndex: _btmNavIndex,
          onItemTapped: onItemTapped,
        );
      case 'Accommodation Rental Company':
        return AccommodationCarRentalNavBar(
          currentIndex: _btmNavIndex,
          onItemTapped: accommodationCarRentalOnItemTapped,
        );
      case 'Car Rental Company':
        return AccommodationCarRentalNavBar(
          currentIndex: _btmNavIndex,
          onItemTapped: accommodationCarRentalOnItemTapped,
        );
      case 'Travel Company':
        return TravelCompanyNavBar(
          currentIndex: _btmNavIndex,
          onItemTapped: travelCompanyOnItemTapped,
        );
      // case 'moderator':
      //   return ModeratorNavBar(
      //     currentIndex: _btmNavIndex,
      //     onItemTapped: onItemTapped,
      //   );
      default:
        return TripifyNavBar(
          currentIndex: _btmNavIndex,
          onItemTapped: onItemTapped,
        );
    }
  }

// Method to return the correct NavBar based on user role
  Widget _buildDrawerBasedOnRole(String role) {
    switch (role) {
      case 'Normal User':
        return TripifyDrawer(
          onItemTapped: onItemTapped,
        );
      case 'Accommodation Rental Company':
        return AccommodationCarRentalDrawer(
          onItemTapped: accommodationCarRentalOnItemTapped,
        );
      case 'Car Rental Company':
        return AccommodationCarRentalDrawer(
          onItemTapped: accommodationCarRentalOnItemTapped,
        );
      case 'Travel Company':
        return TravelCompanyDrawer(
          onItemTapped: travelCompanyOnItemTapped,
        );

      // case 'moderator':
      //   return ModeratorNavBar(
      //     currentIndex: _btmNavIndex,
      //     onItemTapped: onItemTapped,
      //   );
      default:
        return TripifyNavBar(
          currentIndex: _btmNavIndex,
          onItemTapped: onItemTapped,
        );
    }
  }
}
