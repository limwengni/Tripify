import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/views/change_password_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/view_models/auth_service.dart';
import 'package:tripify/views/welcome_page.dart';

class AccountSecurityPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Account Security'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          _buildSection(
            context,
            items: [
              "Change Password",
              "Disable Account",
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection(BuildContext context, {required List<String> items}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF333333) : Colors.white,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            for (int i = 0; i < items.length; i++)
              Column(
                children: [
                  _buildListTile(context, items[i]),
                  if (i < items.length - 1) _buildDivider(isDarkMode),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider(bool isDarkMode) {
    return Divider(
      color: isDarkMode ? Colors.grey[700] : Color(0xFFFBFBFB),
      height: 1,
      thickness: 2,
    );
  }

  Widget _buildListTile(BuildContext context, String title) {
    return ListTile(
      title: Text(
        title,
        textAlign: TextAlign.left,
      ),
      contentPadding: EdgeInsets.zero,
      onTap: () {
        switch (title) {
          case "Change Password":
            // Navigate to Change Password Page
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChangePasswordPage()),
            );
            break;

          case "Disable Account":
            // Show Delete Account confirmation dialog
            _showDeleteAccountDialog(context);
            break;

          default:
            break;
        }
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: isDarkMode ? Color(0xFF333333) : Colors.white,
          title: Text(
            "Disable Account",
            style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
          ),
          content: Text(
            "Are you sure you want to delete your account? This action is irreversible.",
            style: TextStyle(
              color: isDarkMode ? Colors.white : Colors.black,
            ),
          ),
          actions: [
            TextButton(
              child: Text("Cancel",
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                  )),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
                child: Text("Delete",
                    style: TextStyle(
                      color: Colors.red[500],
                    )),
                onPressed: () async {
                  // Show feedback to the user
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Account has been disabled."),
                      backgroundColor: const Color.fromARGB(255, 159, 118, 249),
                    ),
                  );

                  await _disableAccount();

                  showDialog(
                    context: context,
                    barrierDismissible:
                        false, // Prevents closing the dialog by tapping outside
                    builder: (BuildContext context) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  );

                  final authService =
                      Provider.of<AuthService>(context, listen: false);

                  await authService.logout(context);

                  Navigator.of(context).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                  Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => WelcomePage()));
                }),
          ],
        );
      },
    );
  }

  Future<void> _disableAccount() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .get();

        if (!userDoc.exists) {
          print("User document not found.");
          return;
        }

        // Add the status field to the Firestore document
        await FirebaseFirestore.instance
            .collection('User')
            .doc(user.uid)
            .update({
          'status': 'disabled',
        });

        print("Account disabled successfully.");
      }
    } catch (e) {
      print("Error disabling account: $e");
    }
  }
}
