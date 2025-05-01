import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/interceptors/auth_interceptor.dart';

class AuthNetworkImage extends ImageProvider<AuthNetworkImage> {
  final String url;
  static final _sharedClient = AuthInterceptor(http.Client(), null);
  static final _cacheManager = DefaultCacheManager();

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
      final cachedFile = await _cacheManager.getFileFromCache(key.url);
      if (cachedFile != null && await cachedFile.file.exists()) {
        final bytes = await cachedFile.file.readAsBytes();
        return await instantiateImageCodec(bytes);
      }

      final response = await _sharedClient.get(Uri.parse(key.url));
      if (response.statusCode != 200 && response.statusCode != 206) {
        throw Exception('Image load failed: ${response.statusCode}');
      }

      final bytes = response.bodyBytes;

      await _cacheManager.putFile(
        key.url,
        bytes,
        fileExtension: 'jpg',
      );

      return await instantiateImageCodec(bytes);
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

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuthNetworkImage &&
          runtimeType == other.runtimeType &&
          url == other.url;

  @override
  int get hashCode => url.hashCode;
}
