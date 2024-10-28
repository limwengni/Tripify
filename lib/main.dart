import 'package:flutter/material.dart';
import 'package:tripify/navigation/app_routes.dart';
import 'package:tripify/theme/app_theme.dart';
import 'travel_assistant.dart'; // Import your travel assistant file

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: TravelAssistant(),
//     );
//   }
// }

void main() {
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
   MyApp({super.key});
 final appRoutes = AppRoutes();

  @override
  Widget build(BuildContext context) {

    return MaterialApp.router(
      theme: AppTheme.lightTheme, // Using the defined theme
      darkTheme: AppTheme.darkTheme, // Optional dark theme
      themeMode: ThemeMode.system,
      routerConfig: appRoutes.router,
      
    );
  }
}
