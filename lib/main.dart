import 'package:flutter/material.dart';
import 'views/travel_assistant_view.dart';
import 'package:tripify/views/accommodation_requirement_page.dart';
import 'travel_assistant.dart'; // Import your travel assistant file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travis - Travel Assistant',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: TravelAssistantView(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TravelAssistant(),
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
