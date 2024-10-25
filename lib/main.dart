import 'package:flutter/material.dart';
import 'views/travel_assistant_view.dart';

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
    );
  }
}
