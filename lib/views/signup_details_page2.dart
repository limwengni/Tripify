import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripify/main.dart';
import 'package:tripify/models/user_model.dart';
import 'package:tripify/view_models/auth_service.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupDetailsPage2 extends StatefulWidget {
  final String username;
  final DateTime birthDate;
  final File profilePic;
  final String profilePicFilename;

  const SignupDetailsPage2({
    super.key,
    required this.username,
    required this.birthDate,
    required this.profilePic,
    required this.profilePicFilename,
  });

  @override
  _SignupDetailsPage2State createState() => _SignupDetailsPage2State();
}

class _SignupDetailsPage2State extends State<SignupDetailsPage2> {
  AuthService authService = AuthService();
  FirebaseStorageService firebaseStorageService = FirebaseStorageService();
  FirestoreService firestoreService = FirestoreService();

  final _formKey = GlobalKey<FormBuilderState>();
  FilePickerResult? pdf;
  String? selectedOption = 'Normal User';

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
                        name: 'role',
                        validator: FormBuilderValidators.compose([
                          FormBuilderValidators.required(),
                        ]),
                        initialValue:
                            selectedOption, // Set the initial selected option
                        decoration: const InputDecoration(
                          labelText: 'Who are you?',
                          labelStyle: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        options: const [
                          FormBuilderFieldOption(
                              value: 'Normal User', child: Text('Normal User')),
                          FormBuilderFieldOption(
                              value: 'Travel Company',
                              child: Text('Travel Company')),
                          FormBuilderFieldOption(
                              value: 'Accommodation Rental Company',
                              child: Text('Accommodation Rental Company')),
                          FormBuilderFieldOption(
                              value: 'Car Rental Company',
                              child: Text('Car Rental Company')),
                        ],
                        onChanged: (value) {
                          setState(() {
                            selectedOption = value;
                          });
                        },
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      if (selectedOption != 'Normal User') ...[
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
                            onPressed: () async {
                              FilePickerResult? result =
                                  await FilePicker.platform.pickFiles(
                                type: FileType.custom,
                                allowedExtensions: ['pdf'],
                              );

                              if (result != null) {
                                setState(() {
                                  pdf = result;
                                });
                              }
                            },
                            label: Text(
                                pdf != null ? pdf!.files.single.name : 'PDF'),
                            icon: const Icon(Icons.description),
                            backgroundColor:
                                Colors.blue, // Set background color to blue
                          ),
                        ),
                        const SizedBox(height: 15),
                      ],
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
                    onPressed: () async {
                      if (selectedOption != 'Normal User' && pdf != null) {
                        selectedOption =
                            _formKey.currentState?.fields['role']?.value;
                        String? imgDownloadUrl =
                            await firebaseStorageService.saveImageToFirestore(
                                file: widget.profilePic,
                                storagePath:
                                    '${FirebaseAuth.instance.currentUser!.uid}/pfp');
                        String? pdfDownloadUrl =
                            await firebaseStorageService.saveFileToFirestore(
                                file: pdf!,
                                storagePath:
                                    '${FirebaseAuth.instance.currentUser!.uid}/ssm');

                        final user = UserModel(
                            username: widget.username,
                            role: selectedOption!,
                            ssm: '',
                            ssmDownloadUrl: pdfDownloadUrl,
                            bio: '',
                            profilePic: widget.profilePicFilename,
                            birthdate: widget.birthDate,
                            createdAt: DateTime.now(),
                            updatedAt: null,
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            likesCount: 0,
                            commentsCount: 0,
                            savedCount: 0);
                        firestoreService.insertData('User', user.toMap());
                      } else if (selectedOption == 'Normal User') {
                        selectedOption =
                            _formKey.currentState?.fields['role']?.value;
                        String? imgDownloadUrl =
                            await firebaseStorageService.saveImageToFirestore(
                                file: widget.profilePic,
                                storagePath:
                                    '${FirebaseAuth.instance.currentUser!.uid}/pfp');
                        final user = UserModel(
                            username: widget.username,
                            role: selectedOption!,
                            bio: '',
                            profilePic: widget.profilePicFilename,
                            birthdate: widget.birthDate,
                            createdAt: DateTime.now(),
                            updatedAt: null,
                            uid: FirebaseAuth.instance.currentUser!.uid,
                            likesCount: 0,
                            commentsCount: 0,
                            savedCount: 0);
                        firestoreService.insertData('User', user.toMap());
                      } else {
                        print('No PDF file selected');
                        return;
                      }

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (builder) => const MainPage()));
                    },
                    color: Colors.blue,
                    child: const Text(
                      'Next',
                      style: TextStyle(color: Colors.white),
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
