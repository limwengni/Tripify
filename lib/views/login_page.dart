import 'package:flutter/material.dart';
import 'package:tripify/components/components.dart';
import 'package:tripify/constants.dart';
import 'package:tripify/main.dart';
import 'package:tripify/views/welcome_page.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:tripify/views/home_page.dart';
import 'package:provider/provider.dart';
import 'package:tripify/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'login_screen';

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  late String _email;
  late String _password;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, WelcomePage.id);
        return false;
      },
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
                        const ScreenTitle(title: 'Login'),
                        const SizedBox(height: 10),
                        CustomTextField(
                          textField: TextField(
                            onChanged: (value) {
                              _email = value; // Ensure to handle empty cases
                            },
                            decoration: kTextInputDecoration.copyWith(
                              hintText: 'Email',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value; // Ensure to handle empty cases
                            },
                            decoration: kTextInputDecoration.copyWith(
                              hintText: 'Password',
                              hintStyle: const TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomBottomScreen(
                          textButton: 'Login',
                          heroTag: 'login_btn',
                          question: 'Forgot password?',
                          buttonPressed: () async {
                            FocusManager.instance.primaryFocus
                                ?.unfocus(); // Dismiss the keyboard
                            setState(() {
                              _saving = true; // Start loading
                            });

                            // Basic email format validation
                            if (_email.isEmpty || !_email.contains('@')) {
                              setState(() {
                                _saving = false; // Stop loading
                              });
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Error',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  content: const Text(
                                      'Please enter a valid email address.'),
                                  actions: [
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

                            try {
                              // Attempt to sign in and receive a message
                              String? returnAuth =
                                  await authService.signIn(_email, _password);

                              if (returnAuth == "Success") {
                                // Delay briefly to ensure Firebase state updates
                                await Future.delayed(
                                    const Duration(milliseconds: 500));

                                // Navigate to HomePage if login is successful
                                Navigator.of(context).pushReplacement(
                                  MaterialPageRoute(
                                    builder: (context) => const MainPage(),
                                  ),
                                );
                              } else {
                                // Display returned error message if login failed
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Error',
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    content: Text(returnAuth ??
                                        'An unknown error occurred.'),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(context, 'OK'),
                                        child: const Text('OK'),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            } catch (e) {
                              print("Unexpected exception caught: $e");

                              // Handle unexpected errors with a general alert
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Error',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  content: const Text(
                                      'An error occurred. Please try again later.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ),
                              );
                            } finally {
                              // Disable loading overlay after all actions are completed
                              setState(() {
                                _saving = false; // Stop loading
                              });
                            }
                          },
                          questionPressed: () {
                            signUpAlert(
                              onPressed: () async {
                                // await authService.sendPasswordResetEmail(_email);
                              },
                              title: 'RESET YOUR PASSWORD',
                              desc:
                                  'Click on the button to reset your password',
                              btnText: 'Reset Now',
                              context: context,
                            ).show();
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
    );
  }
}
