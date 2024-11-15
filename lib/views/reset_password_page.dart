import 'package:flutter/material.dart';
import 'package:tripify/components/components.dart';
import 'package:tripify/constants.dart';
import 'package:tripify/view_models/auth_service.dart';
import 'package:tripify/views/welcome_page.dart';
import 'package:tripify/theme.dart';
import 'package:loading_overlay/loading_overlay.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:tripify/view_models/auth_service.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});
  static String id = 'reset_password_screen';

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final _auth = FirebaseAuth.instance;
  late String _email = '';
  bool _saving = false;

  final RegExp _emailRegExp = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
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
                Navigator.pop(context);
              },
            ),
            backgroundColor: Colors.transparent,
            elevation: 0,
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
                          const ScreenTitle(title: 'Reset Password'),
                          const SizedBox(height: 10),
                          const Text(
                            'Please enter your email to receive a password reset link.',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          CustomTextField(
                            textField: TextField(
                              cursorColor: Color(0xFF3B3B3B),
                              onChanged: (value) {
                                _email = value;
                              },
                              decoration: kTextInputDecoration.copyWith(
                                  hintText: 'Email',
                                  hintStyle:
                                      const TextStyle(color: Colors.grey)),
                            ),
                          ),
                          const SizedBox(height: 20),
                          CustomButton(
                              buttonText: 'Send Reset Link',
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                setState(() {
                                  _saving = true;
                                });

                                if (_email.isEmpty) {
                                  setState(() {
                                    _saving = false;
                                  });
                                  showDialog(
                                    context: context,
                                    builder: (context) => Theme(
                                      data: lightTheme,
                                      child: AlertDialog(
                                        title: const Text('Error',
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold)),
                                        content: const Text(
                                            'Please enter your email address.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, 'OK'),
                                            child: const Text('OK'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                if (!_emailRegExp.hasMatch(_email)) {
                                  setState(() {
                                    _saving = false;
                                  });
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) => Theme(
                                            data: ThemeData.light(),
                                            child: AlertDialog(
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
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          ));
                                  return;
                                }

                                String returnState = await authService
                                    .resetPassword(email: _email);

                                setState(() {
                                  _saving = false;
                                });

                                if (returnState == "Success") {
                                  showDialog(
                                      context: context,
                                      builder: (context) => Theme(
                                            data: lightTheme,
                                            child: AlertDialog(
                                              title: const Text(
                                                'Success',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: const Text(
                                                  'If an account exists with this email, a password reset link has been sent. Please check your email.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          ));
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) => Theme(
                                            data: ThemeData.light(),
                                            child: AlertDialog(
                                              title: const Text(
                                                'Error',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              content: const Text(
                                                  'Failed to send reset link, please try again later.'),
                                              actions: <Widget>[
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                          context, 'OK'),
                                                  child: const Text('OK'),
                                                ),
                                              ],
                                            ),
                                          ));
                                }
                              }),
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
