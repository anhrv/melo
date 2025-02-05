import 'package:flutter/material.dart';
import 'package:melo_mobile/core/theme/app_themes.dart';
import 'package:melo_mobile/features/auth/view/pages/register_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melo',
      theme: AppTheme.darkTheme,
      home: const RegisterPage(),
    );
  }
}
