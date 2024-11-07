import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:tripify/views/signup_details_page2.dart';

class SignupDetailsPage1 extends StatefulWidget {
  const SignupDetailsPage1({super.key});

  @override
  _SignupDetailsPage1State createState() => _SignupDetailsPage1State();
}

class _SignupDetailsPage1State extends State<SignupDetailsPage1> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FormBuilderTextField(
                        name: 'username',
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        onChanged: (val) {
                          print(val);
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FormBuilderDateTimePicker(
                        name: 'Birth date',
                        inputType: InputType.date,
                        decoration: const InputDecoration(
                          labelText: 'Select Date',
                        ),
                        format: DateFormat('yyyy-MM-dd'),
                      ),
                      const SizedBox(
                        height: 15,
                      ), // Space after the floating action button
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: MaterialButton(
                    padding: const EdgeInsets.all(14.0),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    color: Colors.blue, // Set background color to blue
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Space between the buttons
                Expanded(
                  child: MaterialButton(
                    padding: const EdgeInsets.all(14.0),
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => SignupDetailsPage2()));
                    },
                    color: Colors.blue, // Set background color to blue
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
