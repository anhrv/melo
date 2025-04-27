import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/models/song_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class SongService {
  final BuildContext context;
  late final http.Client _client;

  SongService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<PagedResponse<SongResponse>?> get(
    BuildContext context, {
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

    final url = Uri.parse(ApiConstants.song).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<SongResponse>.fromJson(
          json.decode(response.body), SongResponse.fromJson);
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<List<LovResponse>> getLov(
    BuildContext context, {
    String? name,
  }) async {
    final queryParams = <String, dynamic>{
      "pageSize": "25",
      if (name != null && name.isNotEmpty) 'name': name,
    };

    final url = Uri.parse("${ApiConstants.song}/lov").replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      PagedResponse<LovResponse> res = PagedResponse<LovResponse>.fromJson(
          json.decode(response.body), LovResponse.fromJson);
      return res.data;
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return [];
    }
  }

  Future<SongResponse?> getById(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.song}/$id");

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return SongResponse.fromJson(jsonDecode(response.body));
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

  Future<SongResponse?> create(
    String name,
    DateTime? dateOfRelease,
    List<int>? artistIds,
    List<int>? genreIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse(ApiConstants.song);
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
      }),
    );

    if (response.statusCode == 201) {
      return SongResponse.fromJson(jsonDecode(response.body));
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

  Future<SongResponse?> update(
    int songId,
    String name,
    DateTime? dateOfRelease,
    List<int>? artistIds,
    List<int>? genreIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse('${ApiConstants.song}/$songId');
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
      }),
    );

    if (response.statusCode == 200) {
      return SongResponse.fromJson(jsonDecode(response.body));
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
    int songId,
    File? imageFile,
    BuildContext context,
  ) async {
    final url = Uri.parse('${ApiConstants.song}/$songId/Set-Image');
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
    final url = Uri.parse("${ApiConstants.song}/$id");

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
}
