import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:tripify/main.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/home_page.dart';
import 'package:tripify/views/signup_details_page1.dart';

class VerifyEmailPage extends StatefulWidget {
  @override
  _VerifyEmailPageState createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  bool isEmailVerified = false;
  bool isFirstVisit = true;
  bool isLoading = true; // Added to manage loading state
  Map<String, dynamic>? userData;
  Timer? timer;
  final firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();

    // Fetch user data asynchronously and set loading state
    _initializeUserData();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
    setState(() {
      isLoading = false; // Set loading to false after data is fetched
    });
  }

  Future<void> _initializeUserData() async {
    try {
      userData = await firestoreService.getDataById(
          'User', FirebaseAuth.instance.currentUser!.uid);
      print("User data fetched: $userData");
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) timer?.cancel();
  }

  Future sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;
      await user.sendEmailVerification();

      if (isFirstVisit) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('A verification email has been sent to your email.'),
            duration: Duration(seconds: 2),
          ),
        );
        setState(() {
          isFirstVisit = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Verification email resent!'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Too many requests, please try again later!'),
          duration: Duration(seconds: 2),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (isEmailVerified && userData != null && userData!.isNotEmpty) {
      return const MainPage();
    } else if (isEmailVerified && (userData == null || userData!.isEmpty)) {
      return const SignupDetailsPage1();
    } else {
      return Scaffold(
          body: Center(
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'A verification email has been sent to your email',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              MaterialButton(
                onPressed: sendVerificationEmail,
                color: Colors.blue,
                textColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 15.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.email, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Resend Email'),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        ),
      ));
    }
  }
}
