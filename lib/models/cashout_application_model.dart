import 'package:cloud_firestore/cloud_firestore.dart';

class CashoutApplicationModel {
  final String cashoutId;
  final String createdBy;
  final String accountNumber;
  final String bank;
  final String nameOfAcc;
  final double amount;
  final DateTime createdAt;
  final bool isPaid;
  final String? transactionPic;
  final DateTime? transactionTime;

  CashoutApplicationModel({
    required this.cashoutId,
    required this.createdBy,
    required this.amount,
    required this.accountNumber,
    required this.bank,
    required this.createdAt,
    required this.isPaid,
    required this.nameOfAcc,
    this.transactionPic,
    this.transactionTime,
  });

  /// Converts a Map to a CashoutApplicationMode instance
factory CashoutApplicationModel.fromMap(Map<String, dynamic> map) {
  return CashoutApplicationModel(
    cashoutId: map['cashout_id'] as String,
    createdBy: map['created_by'] as String,
    amount: map['amount'] is double
        ? map['amount'] as double
        : (map['amount'] as num).toDouble(),
    createdAt: DateTime.parse(map['created_at'] as String),
    isPaid: map['is_paid'] as bool,
    accountNumber: map['account_number'] as String,
    nameOfAcc: map['name_of_account'] as String,
    bank: map['bank'] as String,
    transactionPic: map['transaction_pic'] != null
        ? map['transaction_pic'].toString() // Force conversion to string if not null
        : null,
    transactionTime: map['transaction_time'] != null
        ? (map['transaction_time'] is Timestamp
            ? (map['transaction_time'] as Timestamp).toDate()
            : DateTime.tryParse(map['transaction_time'].toString()))
        : null,
  );
}

  /// Converts a CashoutApplicationMode instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'cashout_id': cashoutId,
      'created_by': createdBy,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'is_paid': isPaid,
      'bank': bank,
      'account_number': accountNumber,
      'name_of_account': accountNumber,
      'transaction_pic': transactionPic,
      'transaction_time': transactionTime,
    };
  }
}
