import 'dart:async';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/interceptors/auth_interceptor.dart';

class AuthNetworkImage extends ImageProvider<AuthNetworkImage> {
  final String url;
  final BuildContext context;

  const AuthNetworkImage(this.url, this.context);

  @override
  ImageStreamCompleter loadImage(
    AuthNetworkImage key,
    ImageDecoderCallback decode,
  ) {
    return MultiFrameImageStreamCompleter(
      codec: _loadAsync(key),
      scale: 1.0,
      debugLabel: url,
      informationCollector: () => <DiagnosticsNode>[
        DiagnosticsProperty<ImageProvider>('Image provider', this),
        DiagnosticsProperty<String>('Image URL', url),
      ],
    );
  }

  Future<Codec> _loadAsync(AuthNetworkImage key) async {
    final client = AuthInterceptor(http.Client(), context);
    try {
      final response = await client.get(Uri.parse(key.url));

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('Image load failed: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;
      return await instantiateImageCodec(bytes);
    } finally {
      client.close();
    }
  }

  @override
  Future<AuthNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AuthNetworkImage>(this);
  }
}
