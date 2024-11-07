import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class SignupDetailsPage2 extends StatefulWidget {
  const SignupDetailsPage2({super.key});

  @override
  _SignupDetailsPage2State createState() => _SignupDetailsPage2State();
}

class _SignupDetailsPage2State extends State<SignupDetailsPage2> {
  final _formKey = GlobalKey<FormBuilderState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 65.0, 15.0, 15.0),
              child: Center(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      FormBuilderRadioGroup<String>(
                        name: 'options',
                        decoration: const InputDecoration(
                          labelText: 'Who you are',
                          labelStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        options: const [
                          FormBuilderFieldOption(
                              value: 'Option 1', child: Text('Normal User')),
                          FormBuilderFieldOption(
                              value: 'Option 2', child: Text('Travel Company')),
                          FormBuilderFieldOption(
                              value: 'Option 3',
                              child: Text('Accommodation Rental Company')),
                          FormBuilderFieldOption(
                              value: 'Option 4',
                              child: Text('Car Rental Company')),
                        ],
                        onChanged: (value) {
                          // Optional: handle the selected value here if needed
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      const Text(
                        'SSM',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(
                        height: 5,
                      ),
                      SizedBox(
                        width: 120,
                        child: FloatingActionButton.extended(
                          onPressed: () {},
                          label: const Text('data'),
                          icon: const Icon(Icons.description),
                          backgroundColor:
                              Colors.blue, // Set background color to blue
                        ),
                      ),
                      const SizedBox(
                          height: 15), // Space after the floating action button
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
                      'Back',
                      style: TextStyle(color: Colors.white), // Text color
                    ),
                  ),
                ),
                const SizedBox(width: 10), // Space between the buttons
                Expanded(
                  child: MaterialButton(
                    padding: const EdgeInsets.all(14.0),

                    onPressed: () {
                      // Your action for the second button
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
