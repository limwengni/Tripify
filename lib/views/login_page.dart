import 'package:flutter/material.dart';
import 'package:tripify/components/components.dart';
import 'package:tripify/constants.dart';
import 'package:tripify/views/welcome_page.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:tripify/views/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  static String id = 'login_screen';

  @override
  State<LoginPage> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginPage> {
  final _auth = FirebaseAuth.instance;
  late String _email;
  late String _password;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.popAndPushNamed(context, WelcomePage.id);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
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
                              _email = value;
                            },
                            // style: const TextStyle(
                            //   fontSize: 20,
                            // ),
                            decoration: kTextInputDecoration.copyWith(
                                hintText: 'Email',
                                hintStyle: const TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(height: 10),
                        CustomTextField(
                          textField: TextField(
                            obscureText: true,
                            onChanged: (value) {
                              _password = value;
                            },
                            // style: const TextStyle(
                            //   fontSize: 20,
                            // ),
                            decoration: kTextInputDecoration.copyWith(
                                hintText: 'Password',
                                hintStyle: const TextStyle(color: Colors.grey)),
                          ),
                        ),
                        const SizedBox(height: 20),
                        CustomBottomScreen(
                          textButton: 'Login',
                          heroTag: 'login_btn',
                          question: 'Forgot password?',
                          buttonPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            setState(() {
                              _saving = true;
                            });
                            try {
                              await _auth.signInWithEmailAndPassword(
                                  email: _email, password: _password);

                              if (context.mounted) {
                                setState(() {
                                  _saving = false;
                                  Navigator.popAndPushNamed(
                                      context, LoginPage.id);
                                });
                                Navigator.pushNamed(context, WelcomePage.id);
                              }
                            } catch (e) {
                              signUpAlert(
                                context: context,
                                onPressed: () {
                                  setState(() {
                                    _saving = false;
                                  });
                                  Navigator.popAndPushNamed(
                                      context, LoginPage.id);
                                },
                                title: 'WRONG PASSWORD OR EMAIL',
                                desc:
                                    'Confirm your email and password and try again',
                                btnText: 'Try Now',
                              ).show();
                            }
                          },
                          questionPressed: () {
                            signUpAlert(
                              onPressed: () async {
                                await FirebaseAuth.instance
                                    .sendPasswordResetEmail(email: _email);
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
