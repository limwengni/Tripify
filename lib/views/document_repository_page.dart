import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/views/receipt_repo_page.dart';
import 'package:tripify/views/expired_travel_package_repo_page.dart';
import 'package:tripify/views/resale_travel_package_repo_page.dart';
import 'package:tripify/views/travel_package_on_shelves_repo_page.dart';
import 'package:tripify/views/travel_package_purchased_repository_page.dart';
import 'package:tripify/views/document_upload_page.dart';
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
                  title: const Text("Purchased Travel Package Document"),
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExpiredTravelPackageRepoPage(),
                      ),
                    );
                  },
                ),
              ),
              Card(
                child: ListTile(
                  title: const Text("Resale Travel Package Document"),
                  subtitle: const Text("View your resale travel packages."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ResaleTravelPackageRepoPage(),
                      ),
                    );
                  },
                ),
              ),

              Card(
                child: ListTile(
                    title: const Text("Travel Package On Shelves Document"),
                    subtitle:
                        const Text("View your travel packages on shelves."),
                    trailing: const Icon(Icons.arrow_forward),
                    onTap: () async {
                      String currentUserId =
                          FirebaseAuth.instance.currentUser!.uid;
                      int adsCredit = 0;

                      DocumentSnapshot userDoc = await FirebaseFirestore
                          .instance
                          .collection('User')
                          .doc(currentUserId)
                          .get();

                      if (userDoc.exists) {
                        var data = userDoc.data() as Map<String, dynamic>?;
                        String role = data?['role'] ?? '';

                        if (role == 'Travel Company') {
                          adsCredit = (data?['ads_credit'] ?? 0).toInt();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  TravelPackageOnShelvesRepoPage(
                                      adsCredit: adsCredit),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  "Access denied. You must be a Travel Company."),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } else {
                        print("User not found.");
                      }
                    }),
              ),
              Card(
                child: ListTile(
                  title: const Text("Receipt for Travel Package Purchased"),
                  subtitle: const Text("View your travel packages on shelves."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ReceiptRepoPage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),

              Container(
                margin: EdgeInsets.only(top: 4), // Optional margin for spacing
                height: 2, // Height of the divider
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300], // Color of the divider
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
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DocumentUploadPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              Container(
                margin: EdgeInsets.only(top: 4), // Optional margin for spacing
                height: 2, // Height of the divider
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[800]
                    : Colors.grey[300], // Color of the divider
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
                  subtitle: const Text(
                      "Access your favourite travel posts/packages."),
                  trailing: const Icon(Icons.arrow_forward),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ViewFavouriteTravelPage(),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Container(
              //   margin: EdgeInsets.only(top: 4), // Optional margin for spacing
              //   height: 2, // Height of the divider
              //   color: Theme.of(context).brightness == Brightness.dark
              //       ? Colors.grey[800]
              //       : Colors.grey[300], // Color of the divider
              // ),

              // const SizedBox(height: 16),

              // Request Section
              // const Text(
              //   "Saved Request",
              //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              // ),
              // const SizedBox(height: 8),
              // Card(
              //   child: ListTile(
              //     title: const Text("Saved Accommodation Request"),
              //     subtitle:
              //         const Text("Access your saved accomodation request."),
              //     trailing: const Icon(Icons.arrow_forward),
              //     onTap: () {
              //       // Navigate to View Documents Page
              //     },
              //   ),
              // ),
              // Card(
              //   child: ListTile(
              //     title: const Text("Saved Car Rental Request"),
              //     subtitle: const Text("Access your saved car rental request."),
              //     trailing: const Icon(Icons.arrow_forward),
              //     onTap: () {
              //       // Navigate to View Documents Page
              //     },
              //   ),
              // ),
              // const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
