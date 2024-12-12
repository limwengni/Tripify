import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tripify/models/accommodation_requirement_model.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/models/cashout_application_model.dart';
import 'package:tripify/models/conversation_model.dart';
import 'package:tripify/view_models/firestore_service.dart';
import 'package:tripify/views/chat_page.dart';
import 'package:tripify/views/full_screen_image.dart';
class CashoutCard extends StatefulWidget {
  final CashoutApplicationModel cashoutApplication;

  const CashoutCard({super.key, required this.cashoutApplication});

  @override
  State<StatefulWidget> createState() {
    return _CashoutCardState();
  }
}

class _CashoutCardState extends State<CashoutCard> {
  final FirestoreService _firestoreService = FirestoreService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  bool _isExpanded = false; // Track if the user has clicked "Read More"

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
            Text(
              'Cash Out Amount: RM ${widget.cashoutApplication.amount.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 5),
            // Show more details if _isExpanded is true
            if (_isExpanded) ...[
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
                'Created At: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(widget.cashoutApplication.createdAt)}',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 5),
              // Display the image if available
              if (widget.cashoutApplication.transactionPic != null)
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImage(
                          imageUrl: widget.cashoutApplication.transactionPic!,
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Image.network(
                      widget.cashoutApplication.transactionPic!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          const Text(
                        'Failed to load image',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ),
            ],
            // Read More button to toggle the visibility of the additional fields
            TextButton(
              onPressed: () {
                setState(() {
                  _isExpanded = !_isExpanded; // Toggle the visibility of the additional fields
                });
              },
              child: Text(_isExpanded ? 'Read Less' : 'Read More'),
            ),
          ],
        ),
      ),
    );
  }
}
