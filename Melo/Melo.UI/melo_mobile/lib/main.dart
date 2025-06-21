import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/pages/home_wrapper.dart';
import 'package:melo_mobile/providers/audio_player_service.dart';
import 'package:melo_mobile/providers/user_provider.dart';
import 'package:melo_mobile/services/playlist_service.dart';
import 'package:melo_mobile/services/song_service.dart';
import 'package:melo_mobile/themes/app_themes.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  Stripe.publishableKey = dotenv.env['PUB_KEY']!;
  runApp(
    MultiProvider(
      providers: [
        Provider<SongService>(
          create: (context) => SongService(context),
        ),
        Provider<PlaylistService>(
          create: (context) => PlaylistService(context),
        ),
        Provider<AuthInterceptor>(
          create: (context) => AuthInterceptor(http.Client(), context),
        ),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(
            create: (context) =>
                AudioPlayerService(context.read<SongService>())),
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
