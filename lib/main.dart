import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';

import 'services/auth_service.dart';
import 'views/login_page.dart';
import 'views/home_page.dart';
import 'views/welcome_page.dart';
import 'theme_notifier.dart';
import 'theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeNotifier()),
        ChangeNotifierProvider(create: (context) => AuthService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          debugShowCheckedModeBanner: false,
          home: AuthWrapper(), // Use AuthWrapper for auth state
          routes: {
            LoginPage.id: (context) => const LoginPage(),
            HomePage.id: (context) => const HomePage(),
            WelcomePage.id: (context) => const WelcomePage(),
          },
        );
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    // If the user is logged in, navigate to HomePage, otherwise navigate to WelcomePage
    return authService.user != null ? const HomePage() : const WelcomePage();
  }
}
