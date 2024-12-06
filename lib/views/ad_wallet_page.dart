import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WalletPage extends StatefulWidget {
  final double walletBalance;

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

    Navigator.pop(context);
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
                ? Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 150,
                          height: 20,
                          color: Colors.white,
                        ),
                        SizedBox(height: 10),
                        Row(
                          children: [
                            Icon(Icons.account_balance_wallet, size: 40),
                            SizedBox(width: 10),
                            Container(
                              width: 100,
                              height: 20,
                              color: Colors.white,
                            ),
                          ],
                        ),
                      ],
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
                              Icon(Icons.account_balance_wallet,
                                  size: 40, color: Colors.green),
                              SizedBox(width: 10),
                              Text(
                                "RM${widget.walletBalance.toStringAsFixed(2)}",
                                style: TextStyle(
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
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
                      )),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 10),
            Text(
              "Transaction History",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: 5, // Replace with your actual transaction list count
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text("Transaction ${index + 1}", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
                    subtitle:  Text("Date: ${DateFormat('dd MMM yyyy hh:mm:ss a').format(DateTime.now())}"),
                    trailing: Text(
                      "+RM1000.00", // Replace with actual transaction amount
                      style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
