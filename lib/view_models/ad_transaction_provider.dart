import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tripify/models/ad_transaction_model.dart';
import 'package:tripify/views/topup_receipt_page.dart';

class TransactionProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Function to add a new transaction
  Future<void> addTransaction(
      String userId, int amount, BuildContext context) async {
    try {
      // Get the current timestamp
      DateTime now = DateTime.now();

      DocumentReference docRef =
          await FirebaseFirestore.instance.collection('TopUpTransaction').add({
        'user_id': userId,
        'amount': amount,
        'created_at': now,
      });

      String transactionId = docRef.id;

      AdsTransaction transaction = AdsTransaction(
        transactionId: transactionId,
        userId: userId,
        amount: amount,
        date: now,
      );

      DocumentReference userRef =
          FirebaseFirestore.instance.collection('User').doc(userId);
      DocumentSnapshot userSnapshot = await userRef.get();

      if (userSnapshot.exists) {
        int currentAdsCredit =
            (userSnapshot.data() as Map<String, dynamic>)['ads_credit'] ?? 0;

        await userRef.update({
          'ads_credit': currentAdsCredit + amount,
        });
      }

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(transaction: transaction),
        ),
      );

      print('Transaction successfully added');
    } catch (e) {
      // Handle errors
      print('Error adding transaction: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed. Please try again later.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<List<AdsTransaction>> getTransactionsByUserId(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('TopUpTransaction')
          .where('user_id', isEqualTo: userId)
          .get();

      List<AdsTransaction> transactions = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        return AdsTransaction(
          transactionId: doc.id,
          userId: data['user_id'] ?? '',
          amount: data['amount'] ?? 0,
          date: (data['created_at'] as Timestamp).toDate(),
        );
      }).toList();

      return transactions;
    } catch (e) {
      print('Error fetching transactions for user $userId: $e');
      return [];
    }
  }
}
