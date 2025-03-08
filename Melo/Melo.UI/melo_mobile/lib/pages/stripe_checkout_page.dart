import 'package:flutter/material.dart';
import 'package:melo_mobile/services/subscription_service.dart';

class StripeCheckoutPage extends StatefulWidget {
  @override
  _StripeCheckoutPageState createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  late SubscriptionService _subscriptionService;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(context);
  }

  Future<void> handlePayment() async {
    try {
      await _subscriptionService.handlePayment();
    } catch (e) {
      //
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Subscription')),
      body: Center(
        child: ElevatedButton(
          onPressed: handlePayment,
          child: const Text('Pay Now'),
        ),
      ),
    );
  }
}
