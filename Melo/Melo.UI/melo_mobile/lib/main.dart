import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:melo_mobile/pages/home_wrapper.dart';
import 'package:melo_mobile/themes/app_themes.dart';

Future<void> main() async {
  //await dotenv.load(fileName: "../../.env");
  Stripe.publishableKey = '';
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.darkTheme,
      home: const HomeWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
