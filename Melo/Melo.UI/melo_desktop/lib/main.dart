import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:melo_desktop/interceptors/auth_interceptor.dart';
import 'package:melo_desktop/pages/home_wrapper.dart';
import 'package:melo_desktop/providers/user_provider.dart';
import 'package:melo_desktop/services/song_service.dart';
import 'package:melo_desktop/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        Provider<SongService>(
          create: (context) => SongService(context),
        ),
        Provider<AuthInterceptor>(
          create: (context) => AuthInterceptor(http.Client(), context),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: const MyApp(),
    ),
  );
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
