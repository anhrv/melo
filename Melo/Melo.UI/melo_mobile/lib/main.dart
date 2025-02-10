import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:melo_mobile/core/theme/app_themes.dart';
import 'package:melo_mobile/features/auth/view/pages/login_page.dart';

void main() {
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Melo',
      theme: AppTheme.darkThemeMode,
      home: const LoginPage(),
    );
  }
}
