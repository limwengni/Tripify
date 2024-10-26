import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'theme_notifier.dart';
import 'theme.dart';
import 'views/main_screen_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (context) => ThemeNotifier(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, child) {
        return MaterialApp(
          title: 'Travis - Travel Assistant',
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: themeNotifier.themeMode,
          home: MainScreenView(),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}


// void main() {
//   runApp(MaterialApp(
//     theme: ThemeData(
//       primarySwatch: Colors.blue,
//     ),
//     home: const AccommodationRequirementPage(),
//   ));
// }
