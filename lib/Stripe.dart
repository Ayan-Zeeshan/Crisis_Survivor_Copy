// ignore_for_file: unused_import, non_constant_identifier_names, file_names, use_build_context_synchronously

import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:crisis_survivor/key_constant.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Map<String, dynamic>? paymentIntent;
  TextEditingController amount_controller = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          SizedBox(
            width: 400,
            child: TextField(
              controller: amount_controller, // Fixed variable name
              keyboardType: TextInputType.number, // Ensures numeric input
              maxLength: 10, // Limits input length
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ), // Text styling
              decoration: InputDecoration(
                hintText: "Enter amount",
                labelText: "Amount", // Label above field
                labelStyle: TextStyle(
                  color: Colors.blue,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
                prefixIcon: Icon(
                  Icons.attach_money,
                  color: Colors.green,
                ), // Icon before input
                suffixIcon: Icon(
                  Icons.check_circle,
                  color: Colors.blue,
                ), // Icon after input
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12), // Rounded corners
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ), // Border color & thickness
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.grey,
                    width: 1.5,
                  ), // Normal border
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ), // Border on focus
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Colors.red,
                    width: 2,
                  ), // Border on error
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.redAccent, width: 2),
                ),
                filled: true,
                fillColor: Colors.grey[200], // Light grey background
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ), // Padding inside field
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // print("test 1");
              // Stripe.publishableKey = publishable_key;
              await Stripe.instance.applySettings();
              // print("test 2");
              // await Stripe.instance.applySettings();

              makePayment(amount_controller.text.trim());
              // print("test 3");
            },
            child: const Text("Pay Now "),
          ),
        ],
      ),
    );
  }

  // Future<void> makePayment(String ammount) async {
  //   try {
  //     paymentIntent = await createPaymentIntent(ammount, "PKR");
  //     await Stripe.instance.initPaymentSheet(
  //       paymentSheetParameters: SetupPaymentSheetParameters(
  //         customFlow: true,
  //         merchantDisplayName: 'Makshoof',
  //         paymentIntentClientSecret: paymentIntent!['client_secret'],
  //         googlePay: const PaymentSheetGooglePay(
  //           merchantCountryCode: 'PK',
  //           currencyCode: 'PKR',
  //           testEnv: true,
  //         ),
  //       ),
  //     );

  //     await displayPaymentSheet();
  //   } catch (e) {
  //     log(e.toString());
  //   }
  // }
  Future<void> makePayment(String amount) async {
    try {
      paymentIntent = await createPaymentIntent(amount, "PKR");

      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Makshoof',
          paymentIntentClientSecret: paymentIntent!['client_secret'],
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'PK',
            currencyCode: 'PKR',
            testEnv: true,
          ),
        ),
      );

      await displayPaymentSheet();
    } catch (e) {
      log(e.toString());
    }
  }

  Future<Map<String, dynamic>> createPaymentIntent(
    String amount,
    String currency,
  ) async {
    try {
      Map<String, dynamic> body = {
        'currency': currency,
        'amount': ((int.parse(amount)) * 100).toString(),
        'payment_method_types[]': 'card',
      };

      var response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        body: body,
        headers: {
          'Authorization': 'Bearer your_secret_key',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      return jsonDecode(response.body);
    } catch (e) {
      log(e.toString());
      throw Exception("Failed to create payment intent.");
    }
  }

  Future<void> displayPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment Successful!')));
      paymentIntent = null;
    } on StripeException catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment Failed: ${e.error.localizedMessage}')),
      );
    } catch (e) {
      log(e.toString());
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Payment Failed: $e')));
    }
  }
  //   createPaymentIntent(String amount, String currency) async {
  //     try {
  //       Map<String, dynamic> body = {
  //         'currency': currency,
  //         'amount': ((int.parse(amount)) * 100).toString(),
  //         'payment_method_types[]': 'card',
  //       };

  //       var response = await http.post(
  //         Uri.parse('https://api.stripe.com/v1/payment_intents'),
  //         body: body,
  //         headers: {
  //           'Authorization': 'Bearer $secret_key',
  //           'Content-Type': 'application/x-www-form-urlencoded',
  //         },
  //       );

  //       return jsonDecode(response.body);
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //   }

  //   displayPaymentSheet() async {
  //     try {
  //       await Stripe.instance.presentPaymentSheet().then((value) async {
  //         await Stripe.instance.confirmPaymentSheetPayment();
  //       });
  //       paymentIntent = null;
  //     } on StripeException catch (e) {
  //       log(e.toString());
  //     } catch (e) {
  //       log(e.toString());
  //     }
  //   }
}
