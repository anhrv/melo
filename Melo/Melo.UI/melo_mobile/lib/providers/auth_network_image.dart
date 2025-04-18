import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/interceptors/auth_interceptor.dart';

class AuthNetworkImage extends ImageProvider<AuthNetworkImage> {
  final String url;
  static final _sharedClient = AuthInterceptor(http.Client(), null);

  const AuthNetworkImage(this.url);

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
    try {
      final response = await _sharedClient.get(Uri.parse(key.url));

      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('Image load failed: ${response.statusCode}');
      }

      return await instantiateImageCodec(response.bodyBytes);
    } catch (e) {
      debugPrint('Image load error ($url): $e');
      rethrow;
    }
  }

  @override
  Future<AuthNetworkImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<AuthNetworkImage>(this);
  }

  static void disposeClient() {
    _sharedClient.close();
  }
}
