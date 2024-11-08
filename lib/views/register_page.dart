import 'package:flutter/material.dart';
import 'package:tripify/components/components.dart';
import 'package:tripify/constants.dart';
import 'package:tripify/main.dart';
import 'package:tripify/view_models/auth_service.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/login_page.dart';
import 'package:tripify/views/verify_email_page.dart';
import 'package:tripify/views/welcome_page.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});
  static String id = 'registration_screen';

  @override
  State<RegistrationPage> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationPage> {
  // final _auth = FirebaseAuth.instance;

  late String _email;
  late String _password;
  late String _confirmPassword;
  bool _saving = false;

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, WelcomePage.id);
        return false;
      },
      child: Theme(
        data: ThemeData.light(),
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.popAndPushNamed(context, WelcomePage.id);
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0, // Removes shadow under the AppBar
          ),
          body: LoadingOverlay(
            isLoading: _saving,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const ScreenTitle(title: 'Register'),
                          const SizedBox(height: 10),
                          CustomTextField(
                            textField: TextField(
                              onChanged: (value) {
                                _email = value;
                              },
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            textField: TextField(
                              obscureText: true,
                              onChanged: (value) {
                                _password = value;
                              },
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Password',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 10),
                          CustomTextField(
                            textField: TextField(
                              obscureText: true,
                              onChanged: (value) {
                                _confirmPassword = value;
                              },
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Confirm Password',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomBottomScreen(
                            textButton: 'Sign Up',
                            heroTag: 'signup_btn',
                            question: 'Have an account?',
                            buttonPressed: () async {
                              FocusManager.instance.primaryFocus?.unfocus();
                              setState(() {
                                _saving = true;
                              });
                              if (!_emailRegExp.hasMatch(_email)) {
                                setState(() {
                                  _saving = false; // Reset loading state
                                });
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) =>
                                      AlertDialog(
                                    title: const Text(
                                      'Error',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    content: const Text(
                                        'Please enter a valid email address.'),
                                    actions: <Widget>[
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                                return; 
                              }
                              if (_password == _confirmPassword) {
                                try {
                                  await authService.signUp(_email,_password);
                                  Map<String, dynamic> user = {
                                    "email": _email,
                                    "password": _password
                                  };
                                  setState(() {
                                    _saving = false;
                                  });
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (builder) =>  VerifyEmailPage()));
                                } catch (e) {
                                  setState(() {
                                    _saving = false;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) =>
                                          AlertDialog(
                                            title: const Text(
                                              'Error',
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            content: const Text(
                                                'Failed to register, please try again later'),
                                            actions: <Widget>[
                                              TextButton(
                                                onPressed: () => Navigator.pop(
                                                    context, 'OK'),
                                                child: const Text('OK'),
                                              ),
                                            ],
                                          ));
                                }
                              } else {
                                setState(() {
                                  _saving = false;
                                });
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text(
                                            'Error',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          content: const Text(
                                              'Ensure password and confirm password is match'),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, 'OK'),
                                              child: const Text('OK'),
                                            ),
                                          ],
                                        ));
                              }
                            },
                            questionPressed: () {
                              Navigator.popAndPushNamed(
                                  context, RegistrationPage.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String? signupValidation(String email, String password, String confirmPassword) {
  if (email.isEmpty) {
    return 'Please enter your email address.';
  }
  final RegExp emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  if (!emailRegExp.hasMatch(email)) {
    return 'Please enter a valid email address.';
  }
  if (password != confirmPassword) {
    return 'Ensure password and confirm password is match';
  }
  return null;
}
