import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tripify/main.dart';
import 'package:tripify/theme.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/signup_details_page1.dart';
import 'package:tripify/view_models/user_provider.dart';

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
  DateTime? _lastEmailSentTime;

  FirestoreService firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    _initializeUserData();
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    if (!isEmailVerified) {
      sendVerificationEmail();
      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  Future<void> _initializeUserData() async {
    try {
      userData = await firestoreService.getDataById(
          'User', FirebaseAuth.instance.currentUser!.uid);
      print("User data fetched: $userData");
      if (userData != null) {
        print("Data retrieved successfully: $userData");
        // Handle the data (e.g., map it to a model or display it in the UI)
      } else {
        print("No data found for the given document ID.");
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
    setState(() {
      isLoading = false; // Set loading to false after data is fetched
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> checkEmailVerified() async {
    await FirebaseAuth.instance.currentUser!.reload();
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // fetchUserData(); // Fetch user data once the email is verified
    }
  }

  // Future<void> fetchUserData() async {
  //   final uid = FirebaseAuth.instance.currentUser!.uid;
  //   try {
  //     // Use the UserProvider to fetch user details
  //     await Provider.of<UserProvider>(context, listen: false)
  //         .fetchUserDetails(uid);

  //     // Check if user data is available
  //     if (Provider.of<UserProvider>(context, listen: false).userModel != null &&
  //         Provider.of<UserProvider>(context, listen: false)
  //                 .userModel!
  //                 .username !=
  //             null) {
  //       // Navigate to MainPage if user data is valid
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (_) => const MainPage()),
  //       );
  //     } else {
  //       // Navigate to SignupDetailsPage1 if user data is missing
  //       Navigator.of(context).pushReplacement(
  //         MaterialPageRoute(builder: (_) => const SignupDetailsPage1()),
  //       );
  //     }
  //   } catch (e) {
  //     print("Error fetching user data: $e");
  //   } finally {
  //     setState(() {
  //       isLoading = false; // Ensure loading is set to false after fetching
  //     });
  //   }
  // }

  Future<void> sendVerificationEmail() async {
    try {
      final user = FirebaseAuth.instance.currentUser!;

      if (user.emailVerified) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Your email is already verified.'),
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }

      // Check if there's a recent email verification sent
      if (_lastEmailSentTime != null &&
          DateTime.now().difference(_lastEmailSentTime!).inMinutes < 5) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please wait a few minutes before requesting again.'),
            duration: Duration(seconds: 2),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      await user.sendEmailVerification();
      _lastEmailSentTime = DateTime.now();
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('A verification email has been sent to your email.'),
          duration: Duration(seconds: 2),
        ),
      );
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
    return Theme(
      data: lightTheme, // Set light theme here
      child: Builder(
        builder: (context) {
          if (isLoading) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          } else if (isEmailVerified && userData != null) {
            return const MainPage();
          } else if (isEmailVerified && userData == null) {
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
                        color: Color.fromARGB(255, 159, 118, 249),
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
              ),
            );
          }
        },
      ),
    );
  }
}
