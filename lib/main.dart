import 'package:flutter/material.dart';
import 'views/main_screen_view.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travis - Travel Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: MainScreenView(),
      debugShowCheckedModeBanner: false,
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
