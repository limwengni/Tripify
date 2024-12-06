import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/views/top_up_page.dart';
import 'package:tripify/models/ad_transaction_model.dart';
import 'package:tripify/view_models/ad_transaction_provider.dart';

class WalletPage extends StatefulWidget {
  final int walletBalance;

  WalletPage({required this.walletBalance});

  @override
  _WalletPageState createState() => _WalletPageState();
}

class _WalletPageState extends State<WalletPage> {
  bool walletActivated = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchWalletStatus();
  }

  Future<void> _fetchWalletStatus() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('User')
          .doc(currentUserId)
          .get();

      if (userDoc.exists) {
        setState(() {
          walletActivated = userDoc['wallet_activated'] ?? false;
          isLoading = false;
        });
      } else {
        setState(() {
          walletActivated = false;
          isLoading = false;
        });
      }
    } catch (e) {
      // Handle potential errors
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> activateWallet() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    await FirebaseFirestore.instance.collection('User').doc(currentUserId).set({
      'wallet_activated': true,
      'ads_credit': 0.0,
    }, SetOptions(merge: true));

    setState(() {
      walletActivated = true;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text('Wallet activated successfully!'),
          backgroundColor: Color(0xFF9F76F9)),
    );

    bool isActivated = true;

    Navigator.pop(context, isActivated);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wallet"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            isLoading
                ? Expanded(
                    child: Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF9F76F9)),
                    ),
                  )
                : (walletActivated
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Your Wallet Balance",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          Row(
                            children: [
                              Icon(Icons.account_balance_wallet, size: 40),
                              SizedBox(width: 10),
                              Text(
                                "RM${widget.walletBalance.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 36, fontWeight: FontWeight.bold),
                              ),
                              Spacer(),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => TopUpPage(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF9F76F9),
                                ),
                                child: Text('Top Up',
                                    style: TextStyle(
                                        fontSize: 18, color: Colors.white)),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Expanded(
                        child: Center(
                            child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "Wallet is not yet activated",
                            style: TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: activateWallet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF9F76F9),
                            ),
                            child: Text('Activate Wallet',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white)),
                          ),
                        ],
                      )))),
            SizedBox(height: 20),
            if (walletActivated) ...[
              Divider(),
              SizedBox(height: 10),
              Text(
                "Transaction History",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              FutureBuilder<List<AdsTransaction>>(
                future: TransactionProvider().getTransactionsByUserId(
                    FirebaseAuth.instance.currentUser!.uid),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                        child: Center(
                            child: CircularProgressIndicator(
                                color: Color(0xFF9F76F9))));
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Error fetching transactions.'));
                  }

                  if (snapshot.hasData) {
                    List<AdsTransaction> transactions = snapshot.data ?? [];

                    if (transactions.isEmpty) {
                      return Expanded(
                          child: Center(child: Text('No transactions found.')));
                    }

                    return Expanded(
                      child: ListView.builder(
                        itemCount: transactions
                            .length, // Use the length of actual transactions
                        itemBuilder: (context, index) {
                          final transaction =
                              transactions[index]; // Get the actual transaction

                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              "Transaction ${transaction.transactionId}",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                            subtitle: Text(
                              "Date: ${DateFormat('dd MMM yyyy hh:mm:ss a').format(transaction.date.toLocal())}",
                            ),
                            trailing: Text(
                              "+RM${transaction.amount.toStringAsFixed(2)}", // Display actual transaction amount
                              style: TextStyle(
                                  fontWeight: FontWeight.w500, fontSize: 16),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return Center(child: Text('No transactions found.'));
                },
              )
            ]
          ],
        ),
      ),
    );
  }
}
