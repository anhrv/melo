import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/album_response.dart';
import 'package:melo_mobile/models/is_liked_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class AlbumService {
  final BuildContext context;
  late final http.Client _client;

  AlbumService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<PagedResponse<AlbumResponse>?> get(
    BuildContext context,
    bool liked, {
    required int page,
    String? name,
    String? sortBy,
    bool? ascending,
    List<int>? genreIds,
    List<int>? artistIds,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pagesize': '25',
      if (name != null && name.isNotEmpty) 'name': name,
      if (sortBy != null) 'sortBy': sortBy,
      if (ascending != null) 'ascending': ascending.toString(),
      if (genreIds != null && genreIds.isNotEmpty)
        'genreIds': genreIds.map((id) => id.toString()).toList(),
      if (artistIds != null && artistIds.isNotEmpty)
        'artistIds': artistIds.map((id) => id.toString()).toList(),
    };

    final url =
        Uri.parse(liked ? ApiConstants.likeAlbum : ApiConstants.album).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<AlbumResponse>.fromJson(
          json.decode(response.body), AlbumResponse.fromJson);
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<AlbumResponse?> getById(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.album}/$id");

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return AlbumResponse.fromJson(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          null,
        );
      }
      return null;
    }
  }

  Future<AlbumResponse?> create(
    String name,
    DateTime? dateOfRelease,
    List<int>? artistIds,
    List<int>? genreIds,
    List<int>? songIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse(ApiConstants.album);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        if (dateOfRelease != null)
          'dateOfRelease': dateOfRelease.toIso8601String().substring(0, 10),
        if (artistIds != null && artistIds.isNotEmpty)
          'artistIds': artistIds.map((id) => id.toString()).toList(),
        if (genreIds != null && genreIds.isNotEmpty)
          'genreIds': genreIds.map((id) => id.toString()).toList(),
        if (songIds != null && songIds.isNotEmpty)
          'songIds': songIds.map((id) => id.toString()).toList(),
      }),
    );

    if (response.statusCode == 201) {
      return AlbumResponse.fromJson(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          onFieldErrors,
        );
      }
      return null;
    }
  }

  Future<AlbumResponse?> update(
    int albumId,
    String name,
    DateTime? dateOfRelease,
    List<int>? artistIds,
    List<int>? genreIds,
    List<int>? songIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse('${ApiConstants.album}/$albumId');
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        if (dateOfRelease != null)
          'dateOfRelease': dateOfRelease.toIso8601String().substring(0, 10),
        if (artistIds != null && artistIds.isNotEmpty)
          'artistIds': artistIds.map((id) => id.toString()).toList(),
        if (genreIds != null && genreIds.isNotEmpty)
          'genreIds': genreIds.map((id) => id.toString()).toList(),
        if (songIds != null && songIds.isNotEmpty)
          'songIds': songIds.map((id) => id.toString()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return AlbumResponse.fromJson(jsonDecode(response.body));
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(
          response.body,
          context,
          onFieldErrors,
        );
      }
      return null;
    }
  }

  Future<bool> setImage(
    int albumId,
    File? imageFile,
    BuildContext context,
  ) async {
    final url = Uri.parse('${ApiConstants.album}/$albumId/Set-Image');
    var request = http.MultipartRequest('POST', url);

    if (imageFile != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'ImageFile',
          imageFile.path,
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    } else {
      request.fields['ImageFile'] = 'null';
    }

    final response = await _client.send(request);
    final responseBody = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      return true;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(responseBody, context, null);
      }
      return false;
    }
  }

  Future<bool> delete(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.album}/$id");

    final response = await _client.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 204) {
      return true;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return false;
    }
  }

  Future<bool> isLiked(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.likeAlbum}/$id");

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return IsLikedResponse.fromJson(jsonDecode(response.body)).isLiked;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return false;
    }
  }

  Future<bool> like(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.likeAlbum}/$id");

    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return false;
    }
  }

  Future<bool> unlike(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.likeAlbum}/$id");

    final response = await _client.delete(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return false;
    }
  }
}
