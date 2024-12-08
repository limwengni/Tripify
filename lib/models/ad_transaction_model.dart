import 'package:cloud_firestore/cloud_firestore.dart';

class AdsTransaction {
  final String transactionId;
  final String userId;
  final int amount;
  final DateTime date;
  final String transactionType;

  AdsTransaction({
    required this.transactionId,
    required this.userId,
    required this.amount,
    required this.date,
    required this.transactionType,
  });

  // Convert Transaction object to a Map to store in Firestore
  Map<String, dynamic> toMap() {
    return {
      'transaction_id': transactionId,
      'user_id': userId,
      'amount': amount,
      'created_at': date,
      'type': transactionType,
    };
  }

  // Create Transaction object from Firestore document
  factory AdsTransaction.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AdsTransaction(
      transactionId: doc.id,
      userId: data['user_id'] ?? '',
      amount: data['amount'] ?? 0,
      date: (data['created_at'] as Timestamp).toDate(),
      transactionType: (data['type']),
    );
  }
}
