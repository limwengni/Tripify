import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/group_chat_create_page2.dart';

class GroupChatCreatePage extends StatefulWidget {
  final String currentUserId;
  const GroupChatCreatePage({super.key, required this.currentUserId});

  @override
  _GroupChatCreatePageState createState() => _GroupChatCreatePageState();
}

class _GroupChatCreatePageState extends State<GroupChatCreatePage> {
  final FocusNode _focusNode = FocusNode(); // Declare the FocusNode
  bool isLoading = false; // Track loading state
  final ImagePicker picker = ImagePicker();

  @override
  void dispose() {
    _focusNode.dispose(); // Dispose the FocusNode to avoid memory leaks
    super.dispose();
  }

  final _formKey = GlobalKey<FormBuilderState>();
  FirestoreService firestoreService = FirestoreService();
  TextEditingController controller = TextEditingController();
  XFile? _imageSelected = null;
  String? fileName;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text('Group Chat Create'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          
          children: [
            Expanded(
                child: FormBuilder(
                  key: _formKey,
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      const Text('Add a group chat picture'),
                      const SizedBox(
                        height: 10,
                      ),
                      GestureDetector(
                        onTap: () async {
                          // Pick an image
                          final XFile? imageFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (imageFile != null) {
                            setState(() {
                              _imageSelected =
                                  imageFile; // Store selected image
                              fileName = imageFile.path.split('/').last;
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
                      SizedBox(
                        height: 20,
                      ),
                      FormBuilderTextField(
                        name: 'group name',
                        decoration: const InputDecoration(
                          labelText: 'Group Name',
                          border: OutlineInputBorder(), // Default border color
                        ),
                        onChanged: (val) {
                          print(val);
                        },
                        validator: FormBuilderValidators.required(),
                      ),
                      const SizedBox(height: 10),
                    ],
                  ),
                ),
              
            ),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator()) // Show loader
                  : MaterialButton(
                      padding: const EdgeInsets.all(15),
                      color: const Color.fromARGB(255, 159, 118, 249),
                      onPressed: () {
                        if (_formKey.currentState?.saveAndValidate() ?? false) {
                          if (_imageSelected == null) {
                            // Show an alert dialog or snack bar if no image is selected
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content:
                                    Text('Please select a group chat picture.'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          final formValues = _formKey.currentState?.value;
                          String groupName = formValues?['group name'];
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => GroupChatCreatePage2(
                                groupName: groupName,
                                currentUserId: widget.currentUserId,
                                groupChatPic: File(_imageSelected!.path),
                              ),
                            ),
                          );
                        }
                        ;
                      },
                      child: const Text(
                        'Create',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
