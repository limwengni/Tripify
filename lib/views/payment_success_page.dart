import 'package:flutter/material.dart';
import 'package:tripify/main.dart';

class PaymentSuccessPage extends StatelessWidget {
  // You can add any parameters here, such as payment amount or order details
  final String orderId;
  final double totalAmount;

  PaymentSuccessPage(
      {Key? key, required this.orderId, required this.totalAmount})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Successful'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle_outline,
                size: 100.0,
                color: Colors.green,
              ),
              const SizedBox(height: 20),
              const Text(
                'Your payment was successful!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              Text(
                'Travel Package: $orderId',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              Text(
                'Total Amount: RM${totalAmount.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  // Navigate back or to another screen (e.g., Home or Orders Page)
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
