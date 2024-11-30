import 'package:dio/dio.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:tripify/view_models/stripe_key.dart';

class StripeService {
  StripeService._();

  // Singleton
  static final StripeService instance = StripeService._();

  Future<bool> makePayment(double amount, String currency) async {
    try {
      // Step 1: Create Payment Intent
      String? paymentIntentClientSecret =
          await _createPaymentIntent(amount, currency);
      if (paymentIntentClientSecret == null) return false;

      // Step 2: Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: 'Tripify',
        ),
      );

      // Step 3: Process the Payment
      await _processPayment();

      // If no errors, payment is successful
      return true;
    } catch (e) {
      print("Payment Error: $e");
      return false; // Payment failed
    }
  }

  Future<String?> _createPaymentIntent(double amount, String currency) async {
    try {
      final Dio dio = Dio();
      Map<String, dynamic> data = {
        'amount': _calculateAmount(amount), // Stripe expects amount in cents
        'currency': currency,
      };
      var response = await dio.post(
        'https://api.stripe.com/v1/payment_intents',
        data: data,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          headers: {
            'Authorization': 'Bearer ${stripeSecretKey}',
            'Content-Type': 'application/x-www-form-urlencoded',
          },
        ),
      );

      if (response.data != null) {
        return response.data['client_secret'];
      }
    } catch (e) {
      print("Create Payment Intent Error: $e");
    }
    return null;
  }

  Future<void> _processPayment() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      // await Stripe.instance.confirmPaymentSheetPayment();
    } catch (e) {
      print("Process Payment Error: $e");
      throw Exception('Payment failed'); // Ensure payment failure is handled
    }
  }

  String _calculateAmount(double amount) {
    final calculatedAmount = (amount * 100).toInt(); // Convert to cents
    return calculatedAmount.toString();
  }
}
