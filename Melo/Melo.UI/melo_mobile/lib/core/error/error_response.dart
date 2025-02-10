import 'dart:convert';

import 'package:collection/collection.dart';

class ErrorResponse {
  final int status;
  final String title;
  final String type;
  String? traceId;
  final Map<String, dynamic> errors;

  ErrorResponse({
    required this.status,
    required this.title,
    required this.type,
    this.traceId,
    required this.errors,
  });

  ErrorResponse copyWith({
    int? status,
    String? title,
    String? type,
    String? traceId,
    Map<String, dynamic>? errors,
  }) {
    return ErrorResponse(
      status: status ?? this.status,
      title: title ?? this.title,
      type: type ?? this.type,
      traceId: traceId ?? this.traceId,
      errors: errors ?? this.errors,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'status': status,
      'title': title,
      'type': type,
      'traceId': traceId,
      'errors': errors,
    };
  }

  factory ErrorResponse.fromMap(Map<String, dynamic> map) {
    return ErrorResponse(
      status: map['status'] as int,
      title: map['title'] as String,
      type: map['type'] as String,
      traceId: map['traceId'] != null ? map['traceId'] as String : null,
      errors: Map<String, dynamic>.from(
        (map['errors'] as Map<String, dynamic>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory ErrorResponse.fromJson(String source) =>
      ErrorResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'ErrorResponse(status: $status, title: $title, type: $type, traceId: $traceId, errors: $errors)';
  }

  @override
  bool operator ==(covariant ErrorResponse other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.status == status &&
        other.title == title &&
        other.type == type &&
        other.traceId == traceId &&
        mapEquals(other.errors, errors);
  }

  @override
  int get hashCode {
    return status.hashCode ^
        title.hashCode ^
        type.hashCode ^
        traceId.hashCode ^
        errors.hashCode;
  }

  factory ErrorResponse.customErrorReponse({
    int status = 0,
    String title = "Error has occured",
    String type = "Error",
    String? traceId,
    String? message,
  }) {
    final errors = <String, List<String>>{
      "errors": [message ?? title],
    };
    return ErrorResponse(
      status: status,
      title: title,
      type: type,
      traceId: traceId,
      errors: errors,
    );
  }
}
