import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme_notifier.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  static const String id = 'home_screen';

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Text('Welcome to Tripify!'),
    );
  }
}