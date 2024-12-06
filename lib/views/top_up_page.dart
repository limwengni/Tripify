import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tripify/view_models/stripe_service.dart';
import 'package:tripify/view_models/ad_transaction_provider.dart';

class TopUpPage extends StatefulWidget {
  @override
  _TopUpPageState createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  bool _isProcessing = false;

  final List<int> predefinedAmounts = [50, 100, 300];
  int selectedAmount = 0;

  // Function to handle top-up
  Future<void> _topUpWallet() async {
    int topUpAmount = selectedAmount;
    final amount = topUpAmount.toDouble();

    if (topUpAmount == null || topUpAmount <= 0) {
      // Show error if amount is invalid
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please enter a valid amount'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    try {
      final paymentSuccess = await StripeService.instance.makePayment(
        amount,
        'myr',
      );

      if (amount != null) topUpAmount = amount.toInt();

      String userId = FirebaseAuth.instance.currentUser!.uid;

      if (paymentSuccess) {
        TransactionProvider().addTransaction(userId, topUpAmount, context);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment Successful!'),
          backgroundColor: Color(0xFF9F76F9),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Payment Failed!'),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      print("Error during top-up: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('An error occurred during payment.'),
        backgroundColor: Colors.red,
      ));
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Up Wallet')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Select Top Up Amount",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: predefinedAmounts.map(
                  (amount) {
                    return SizedBox(
                        height: 50.0,
                        child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                selectedAmount = amount;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: selectedAmount == amount
                                  ? Colors.blueAccent
                                  : null,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'RM $amount',
                                style: selectedAmount == amount
                                    ? TextStyle(
                                        fontSize: 16, color: Colors.white)
                                    : TextStyle(fontSize: 16),
                              ),
                            )));
                  },
                ).toList()),
            SizedBox(height: 20),
            _isProcessing
                ? Center(
                    child: CircularProgressIndicator(
                        color: const Color.fromARGB(255, 159, 118, 249)))
                : (selectedAmount != 0)
                    ? ElevatedButton(
                        onPressed: _topUpWallet,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 159, 118, 249),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size(double.infinity, 48),
                        ),
                        child: Text(
                          'Top Up Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 159, 118, 249),
                          padding: EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size(double.infinity, 48),
                        ),
                        child: Text(
                          'Top Up Now',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
            SizedBox(height: 20),
            Text(
              'Secure Payment Powered by Stripe',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
