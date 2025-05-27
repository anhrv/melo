import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:melo_mobile/constants/api_constants.dart';
import 'package:melo_mobile/interceptors/auth_interceptor.dart';
import 'package:melo_mobile/models/playlist_response.dart';
import 'package:melo_mobile/models/lov_response.dart';
import 'package:melo_mobile/models/paged_response.dart';
import 'package:melo_mobile/models/playlist_song_response.dart';
import 'package:melo_mobile/utils/api_error_handler.dart';

class PlaylistService {
  final BuildContext context;
  late final http.Client _client;

  PlaylistService(this.context) {
    _client = AuthInterceptor(http.Client(), context);
  }

  Future<PagedResponse<PlaylistResponse>?> get(
    BuildContext context, {
    required int page,
    String? name,
    String? sortBy,
    bool? ascending,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pagesize': '25',
      if (name != null && name.isNotEmpty) 'name': name,
      if (sortBy != null) 'sortBy': sortBy,
      if (ascending != null) 'ascending': ascending.toString(),
    };

    final url = Uri.parse(ApiConstants.playlist).replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<PlaylistResponse>.fromJson(
          json.decode(response.body), PlaylistResponse.fromJson);
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

    final url = Uri.parse("${ApiConstants.playlist}/lov").replace(
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

  Future<PlaylistResponse?> getById(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.playlist}/$id");

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PlaylistResponse.fromJson(jsonDecode(response.body));
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

  Future<PagedResponse<PlaylistSongResponse>?> getSongs(BuildContext context,
      {required int playlistId, required int page, int pagesize = 25}) async {
    final queryParams = <String, dynamic>{
      'page': page.toString(),
      'pagesize': pagesize.toString(),
    };

    final url =
        Uri.parse(ApiConstants.playlist + "/$playlistId/get-songs").replace(
      queryParameters: queryParams,
    );

    final response = await _client.get(
      url,
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      return PagedResponse<PlaylistSongResponse>.fromJson(
          json.decode(response.body), PlaylistSongResponse.fromJson);
    } else {
      if (context.mounted) {
        ApiErrorHandler.handleErrorResponse(response.body, context, null);
      }
      return null;
    }
  }

  Future<bool> removeSong(
    BuildContext context, {
    required int playlistId,
    required List<int> songIds,
  }) async {
    final url = Uri.parse(ApiConstants.playlist + "/$playlistId/remove-songs");

    final response = await _client.delete(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'songIds': songIds}),
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

  Future<bool> reorderSongs(
    BuildContext context, {
    required int playlistId,
    required List<int> songIds,
  }) async {
    final url = Uri.parse(ApiConstants.playlist + "/$playlistId/reorder-songs");

    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'songIds': songIds}),
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

  Future<PlaylistResponse?> create(
    String name,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse(ApiConstants.playlist);
    final response = await _client.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 201) {
      return PlaylistResponse.fromJson(jsonDecode(response.body));
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

  Future<PlaylistResponse?> update(
    int playlistId,
    String name,
    BuildContext context,
    Function(Map<String, String>) onFieldErrors,
  ) async {
    final url = Uri.parse('${ApiConstants.playlist}/$playlistId');
    final response = await _client.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name}),
    );

    if (response.statusCode == 200) {
      return PlaylistResponse.fromJson(jsonDecode(response.body));
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

  Future<bool> delete(
    int id,
    BuildContext context,
  ) async {
    final url = Uri.parse("${ApiConstants.playlist}/$id");

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
