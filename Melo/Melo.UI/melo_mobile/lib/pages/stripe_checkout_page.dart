import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:melo_mobile/services/auth_service.dart';
import 'package:melo_mobile/services/subscription_service.dart';
import 'package:melo_mobile/themes/app_colors.dart';
import 'package:melo_mobile/widgets/loading_overlay.dart';

class StripeCheckoutPage extends StatefulWidget {
  const StripeCheckoutPage({super.key});

  @override
  State<StripeCheckoutPage> createState() => _StripeCheckoutPageState();
}

class _StripeCheckoutPageState extends State<StripeCheckoutPage> {
  bool _isLoading = false;
  bool _isSubscriptionLoading = false;
  late SubscriptionService _subscriptionService;
  late AuthService _authService;

  @override
  void initState() {
    super.initState();
    _subscriptionService = SubscriptionService(context);
    _authService = AuthService(context);
  }

  Future<void> handlePayment() async {
    if (_isSubscriptionLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSubscriptionLoading = true);
    try {
      await _subscriptionService.handlePayment();
    } catch (e) {
      //
    } finally {
      if (mounted) {
        setState(() => _isSubscriptionLoading = false);
      }
    }
  }

  void _logout() async {
    if (_isLoading) return;
    FocusScope.of(context).unfocus();
    setState(() => _isLoading = true);

    try {
      await _authService.logout(
        context,
      );
    } catch (ex) {
      //
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const double verticalPadding = 38.0;
    return LoadingOverlay(
      isLoading: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          shape: const Border(bottom: BorderSide.none),
        ),
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
                          'In order to use the Melo platform, you must be a subscribed user.\nSubscriptions are a recurring charge.\nYou can cancel your subscription at any time, but be aware that your money will not be refunded.\nClick the button below to subscribe and begin your Melo journey.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 32),

                        // Payment Button
                        ElevatedButton(
                          onPressed:
                              _isSubscriptionLoading ? null : handlePayment,
                          child: _isSubscriptionLoading
                              ? const Text('Please wait')
                              : const Text('Subscribe'),
                        ),
                        const SizedBox(height: 32),

                        Center(
                          child: RichText(
                            text: TextSpan(
                              text: "Login with a different account",
                              style:
                                  const TextStyle(color: AppColors.secondary),
                              recognizer: TapGestureRecognizer()
                                ..onTap =
                                    _isSubscriptionLoading ? null : _logout,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
