import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePasswordPage extends StatefulWidget {
  @override
  _ChangePasswordPageState createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  String _newPassword = '';
  String _confirmPassword = '';
  bool _saving = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Change Password'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a new password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                onChanged: (value) {
                  _newPassword = value;
                },
              ),
              SizedBox(height: 20),
              TextFormField(
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _newPassword) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                onChanged: (value) {
                  _confirmPassword = value;
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saving
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _saving = true;
                          });

                          try {
                            // Get the current user
                            User? user = _auth.currentUser;

                            if (user != null) {
                              // Update the user's password
                              await user.updatePassword(_newPassword);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Password updated successfully!',
                                    style: TextStyle(
                                        color: Colors.white), // Text color
                                  ),
                                  backgroundColor: Color.fromARGB(
                                      255, 159, 118, 249), // Background color
                                ),
                              );

                              Navigator.pop(context);
                            } else {
                              throw FirebaseAuthException(
                                  code: 'no-user',
                                  message:
                                      'No authenticated user found. Please log in again.');
                            }
                          } on FirebaseAuthException catch (e) {
                            String errorMessage;

                            switch (e.code) {
                              case 'requires-recent-login':
                                errorMessage =
                                    'This operation requires recent login. Please log in again.';
                                break;
                              default:
                                errorMessage =
                                    'An error occurred while changing password: ${e.message}';
                            }

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(errorMessage),
                              ),
                            );
                          } finally {
                            setState(() {
                              _saving = false;
                            });
                          }
                        }
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromARGB(
                      255, 159, 118, 249), // Button background color
                ),
                child: _saving
                    ? CircularProgressIndicator(
                        color: Colors.white, // CircularProgressIndicator color
                      )
                    : Text(
                        'Update Password',
                        style: TextStyle(color: Colors.white), // Text color
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
