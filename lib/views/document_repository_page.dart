import 'package:flutter/material.dart';
import 'package:tripify/views/travel_package_purchased_repository_page.dart';

class DocumentRepositoryPage extends StatelessWidget {
  const DocumentRepositoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
        child: TextButton(
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (builder) => TravelPackagePurchasedRepositoryPage()));
      },
      child: const Text('button'),
    ));
  }
}
