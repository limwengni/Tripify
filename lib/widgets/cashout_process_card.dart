import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/view_models/firesbase_storage_service.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/chat_page.dart';
import 'package:tripify/views/full_screen_image.dart';

class CashoutProcessCard extends StatefulWidget {
  final CashoutApplicationModel cashoutApplication;

  const CashoutProcessCard({super.key, required this.cashoutApplication});

  @override
  State<StatefulWidget> createState() {
    return _CashoutProcessCardState();
  }
}

class _CashoutProcessCardState extends State<CashoutProcessCard> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseStorageService _firebaseStorageService =
      FirebaseStorageService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  XFile? _imageSelected = null;
  String? fileName;
  final ImagePicker picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.cashoutApplication.cashoutId,
              style: const TextStyle(
                fontWeight: FontWeight.bold, // Makes the text bold
                fontSize: 17, // Adjust size for a title
              ),
            ),
            const SizedBox(height: 5),
            Text(
              'Status: ${widget.cashoutApplication.isPaid ? "Completed" : "Pending"}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            widget.cashoutApplication.transactionTime != null
                ? Text(
                    'Transaction Time: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.cashoutApplication.transactionTime!)}',
                    style: const TextStyle(fontSize: 16),
                  )
                : const Text(
                    'Transaction Time: Not available',
                    style: TextStyle(fontSize: 16),
                  ),
            const SizedBox(height: 5),
            Text(
              'Cash Out Amount: RM ${widget.cashoutApplication.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Text(
              'Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.cashoutApplication.createdAt)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (widget.cashoutApplication.isPaid == true)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FullScreenImage(
                            imageUrl: widget.cashoutApplication.transactionPic!,
                          ),
                        ),
                      );

                    },
                    style: TextButton.styleFrom(
                      backgroundColor: const Color.fromARGB(
                          255, 159, 118, 249), // Blue background color
                      foregroundColor: Colors
                          .white, // Text color (white text on blue background)
                      padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12), // Optional: adjust padding
                    ),
                    child: const Text('Transaction Pic'),
                  )
                else
                  SizedBox.shrink(),
                SizedBox(
                  width: 5,
                ),
                TextButton(
                  onPressed: widget.cashoutApplication.isPaid == false
                      ? () async {
                          final XFile? imageFile = await picker.pickImage(
                              source: ImageSource.gallery);

                          if (imageFile != null) {
                            try {
                              // Save the image to Firebase Storage
                              String? imgDownloadUrl =
                                  await _firebaseStorageService
                                      .saveImageVideoToFirestore(
                                          file: File(imageFile.path),
                                          storagePath: 'cashOut');

                              // Update the Firestore document with the image URL
                              await _firestoreService.updateField(
                                  'Cashout_Applications',
                                  widget.cashoutApplication.cashoutId,
                                  'transaction_pic',
                                  imgDownloadUrl);

                              // Update the 'is_paid' field in Firestore
                              await _firestoreService.updateField(
                                  'Cashout_Applications',
                                  widget.cashoutApplication.cashoutId,
                                  'is_paid',
                                  true);

                                  await _firestoreService.updateField('Cashout_Applications', widget.cashoutApplication.cashoutId, 'transaction_time', DateTime.now());

                              await _firestoreService.updateField('User', widget.cashoutApplication.createdBy, 'cashout_amount', 0);
                              

                              // Optionally, show a success message
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text(
                                        'Process completed successfully!')),
                              );
                            } catch (e) {
                              // Handle errors if something goes wrong
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Process failed: $e')),
                              );
                            }
                          } else {
                            // If no image was selected, show an error message
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'No image selected. Please try again.')),
                            );
                          }
                        }
                      : null,
                  style: TextButton.styleFrom(
                    backgroundColor: const Color.fromARGB(
                        255, 159, 118, 249), // Blue background color
                    foregroundColor: Colors
                        .white, // Text color (white text on blue background)
                    padding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 12), // Optional: adjust padding
                  ),
                  child: widget.cashoutApplication.isPaid == true
                      ? const Text('Completed')
                      : const Text('Complete'),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
