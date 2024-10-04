import 'package:flutter/material.dart';
import 'travel_assistant.dart';  // Import your travel assistant file

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel Assistant',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TravelAssistant(),
      debugShowCheckedModeBanner: false
    );
  }
}
