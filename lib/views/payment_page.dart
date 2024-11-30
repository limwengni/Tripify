import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

class PaymentScreen extends StatefulWidget {
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  // Function to create and confirm a payment
  Future<void> _processPayment() async {
    try {
      // 1. Call your backend to create a PaymentIntent
      final paymentIntentClientSecret = await _createPaymentIntent();

      // 2. Initialize the payment method and confirm the payment
      // await Stripe.instance.confirmPayment(
      //   PaymentIntent(
      //     clientSecret: paymentIntentClientSecret,
      //   ),
      // );
      
      // 3. Handle the result
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Successful')),
      );
    } catch (e) {
      // Handle errors
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed')),
      );
    }
  }

  // Simulating a backend call to create a PaymentIntent
  Future<String> _createPaymentIntent() async {
    // Call your backend to create a PaymentIntent
    // Replace this with your backend logic to create the PaymentIntent
    // and return the client secret

    // For the purpose of this example, we simulate a payment intent
    return 'your_payment_intent_client_secret'; // Replace with your client secret
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stripe Payment Example')),
      body: Center(
        child: ElevatedButton(
          onPressed: _processPayment,
          child: Text('Pay Now'),
        ),
      ),
    );
  }
}
