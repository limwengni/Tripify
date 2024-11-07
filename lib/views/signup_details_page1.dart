import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripify/views/signup_details_page2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'dart:io';

class SignupDetailsPage1 extends StatefulWidget {
  const SignupDetailsPage1({super.key});

  @override
  _SignupDetailsPage1State createState() => _SignupDetailsPage1State();
}

class _SignupDetailsPage1State extends State<SignupDetailsPage1> {
  final ImagePicker picker = ImagePicker();
  final _formKey = GlobalKey<FormBuilderState>();
  String? _username;
  DateTime? _birthDate;
  XFile? _imageSelected = null;

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
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Add a profile picture'),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Pick an image
                          final XFile? imageFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (_imageSelected == null) {
                            setState(() {
                              _imageSelected =
                                  imageFile; // Store selected image
                            });
                          }
                        },
                        child: CircleAvatar(
                          radius: 70,
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: _imageSelected != null
                              ? FileImage(File(_imageSelected!.path))
                              : null,
                          child: _imageSelected == null
                              ? const Icon(
                                  Icons.add,
                                  size: 45,
                                )
                              : null, // Only show the icon if no image is selected
                        ),
                      ),
                      FormBuilderTextField(
                        name: 'username',
                        decoration:
                            const InputDecoration(labelText: 'Username'),
                        onChanged: (val) {
                          print(val);
                        },
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      FormBuilderDateTimePicker(
                        name: 'Birth date',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        inputType: InputType.date,
                        decoration: const InputDecoration(
                          labelText: 'Select Date',
                        ),
                        format: DateFormat('yyyy-MM-dd'),
                      ),
                      const SizedBox(
                        height: 15,
                      ),
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
                    color: Colors.blue,
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: MaterialButton(
                    padding: const EdgeInsets.all(14.0),
                    onPressed: () {
                      bool valid =
                          _formKey.currentState?.saveAndValidate() ?? false;
                      if (!valid || _imageSelected == null) {
                        showDialog(
                            context: context,
                            builder: (BuildContext context) => AlertDialog(
                                  title: const Text(
                                    'Error',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  content: const Text(
                                      'Please ensure all fields are filled correctly.'),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.pop(context, 'OK'),
                                      child: const Text('OK'),
                                    ),
                                  ],
                                ));
                        return;
                      } else {
                        _username = _formKey.currentState!.value['username'];
                        _birthDate = _formKey.currentState!.value['Birth date'];
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (builder) => SignupDetailsPage2(
                              username: _username!,
                              birthDate: _birthDate!,
                              profilePic: File(_imageSelected!.path),
                            ),
                          ),
                        );
                      }
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
