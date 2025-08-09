import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:melo_desktop/constants/api_constants.dart';
import 'package:melo_desktop/interceptors/auth_interceptor.dart';
import 'package:melo_desktop/models/artist_response.dart';
import 'package:melo_desktop/models/lov_response.dart';
import 'package:melo_desktop/models/paged_response.dart';
import 'package:melo_desktop/utils/api_error_handler.dart';

class ArtistService {
  final BuildContext context;
  late final http.Client _client;

  ArtistService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<PagedResponse<ArtistResponse>?> get(
    BuildContext context, {
    required int page,
    String? name,
    String? sortBy,
    bool? ascending,
    List<int>? genreIds,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pagesize': '25',
      if (name != null && name.isNotEmpty) 'name': name,
      if (sortBy != null) 'sortBy': sortBy,
      if (ascending != null) 'ascending': ascending.toString(),
      if (genreIds != null && genreIds.isNotEmpty)
        'genreIds': genreIds.map((id) => id.toString()).toList(),
    };

    final url = Uri.parse(ApiConstants.artist).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<ArtistResponse>.fromJson(
          json.decode(response.body), ArtistResponse.fromJson);
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

    final url = Uri.parse("${ApiConstants.artist}/lov").replace(
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

  Future<ArtistResponse?> getById(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.artist}/$id");

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return ArtistResponse.fromJson(jsonDecode(response.body));
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

  Future<ArtistResponse?> create(
    String name,
    List<int>? genreIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse(ApiConstants.artist);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        if (genreIds != null && genreIds.isNotEmpty)
          'genreIds': genreIds.map((id) => id.toString()).toList(),
      }),
    );

    if (response.statusCode == 201) {
      return ArtistResponse.fromJson(jsonDecode(response.body));
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

  Future<ArtistResponse?> update(
    int artistId,
    String name,
    List<int>? genreIds,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse('${ApiConstants.artist}/$artistId');
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        if (genreIds != null && genreIds.isNotEmpty)
          'genreIds': genreIds.map((id) => id.toString()).toList(),
      }),
    );

    if (response.statusCode == 200) {
      return ArtistResponse.fromJson(jsonDecode(response.body));
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
    int artistId,
    File? imageFile,
    BuildContext context,
  ) async {
    final url = Uri.parse('${ApiConstants.artist}/$artistId/Set-Image');
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
    final url = Uri.parse("${ApiConstants.artist}/$id");

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
