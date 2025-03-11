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
    const double verticalPadding = 24.0;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: constraints.maxHeight - (verticalPadding * 2),
              ),
              child: Center(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: verticalPadding),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Title
                      const Text(
                        'Subscription',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      const Text(
                        'In order to use the Melo platform, you must be a subscribed user.\nSubscriptions cost only \$1.00 and are charged monthly.\nYou can cancel your subscription at any time, but be aware that your money will not be refunded.\nClick the button below to subscribe and begin your Melo journey.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Payment Button
                      ElevatedButton(
                        onPressed: handlePayment,
                        child: const Text('Subscribe'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
