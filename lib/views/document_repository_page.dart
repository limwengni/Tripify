import 'package:flutter/material.dart';
import 'package:tripify/views/travel_package_purchased_repository_page.dart';
import 'package:tripify/views/view_fav_post_page.dart';


class DocumentRepositoryPage extends StatelessWidget {
  const DocumentRepositoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Travel Package Repository Section
              const Text(
                "Travel Package Repository",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text("Store Travel Package Document"),
                  subtitle: const Text("Access your purchased documents here."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TravelPackagePurchasedRepositoryPage(),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Expired Travel Package Document"),
                  subtitle: const Text("View your expired travel packages."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to Expired Travel Package Page
                  },
                ),
              ),
              const SizedBox(height: 16),

              // Repository Section
              const Text(
                "Repository",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text("View Documents"),
                  subtitle: const Text("Access all stored documents."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    // Navigate to View Documents Page
                  },
                ),
              ),
              const SizedBox(height: 16),

              // User's Favourite Repository Section
              const Text(
                "User's Favourite Repository",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Card(
                child: ListTile(
                  title: const Text("View Favourite Travel Post/Package"),
                  subtitle:
                      const Text("Access your favourite travel posts/packages."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ViewFavouriteTravelPage(),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
