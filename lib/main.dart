import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Stripe.publishableKey = "your publishable key here";
  await Stripe.instance.applySettings();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ' ',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(),
      home: const PaymentPage(),
    );
  }
}

class PaymentPage extends StatelessWidget {
  const PaymentPage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Future<void> initPaymentSheet(context, {String email, int amount}) async {
      try {
        // 1. create payment intent on the server
        final response = await http.post(
            Uri.parse(
                'your firebase function URL here'),
            body: {
              'email': email,
              'amount': amount.toString(),
            });

        final jsonResponse = jsonDecode(response.body);
        log(jsonResponse.toString());

        //2. initialize the payment sheet
        await Stripe.instance.initPaymentSheet(
          paymentSheetParameters: SetupPaymentSheetParameters(
            // testEnv: true,
            // merchantCountryCode: 'US',
            paymentIntentClientSecret: jsonResponse['paymentIntent'],
            merchantDisplayName: 'Flutter Stripe Store Demo',
            customerId: jsonResponse['customer'],
            customerEphemeralKeySecret: jsonResponse['ephemeralKey'],
            style: ThemeMode.light,
          ),
        );

        await Stripe.instance.presentPaymentSheet();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment completed!')),
        );
      } catch (e) {
        if (e is StripeException) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(' ${e.error.localizedMessage}'),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(' $e')),
          );
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(""),
        backgroundColor: const Color(0XFF6773e6),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                height: 60,
                child: Image.asset("assets/image/stripe-logo-blue.png")),
            const SizedBox(
              height: 150,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: const Color(0XFF6773e6),
                onPrimary: Colors.white,
                shadowColor: Colors.grey,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(38),
                ),
                padding: const EdgeInsets.fromLTRB(90, 22, 90, 22),
              ),
              onPressed: () async {
                await initPaymentSheet(context,
                    email: "example@gmail.com", amount: 200000);
              },
              child: const Text(
                'Pay',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
            ),
            Container(height: 100, child: Image.asset("assets/image/card.png")),
          ],
        ),
      ),
    );
  }
}
