import 'dart:convert';

class TokenResponse {
  final String accessToken;
  final String refreshToken;

  TokenResponse({
    required this.accessToken,
    required this.refreshToken,
  });

  TokenResponse copyWith({
    String? accessToken,
    String? refreshToken,
  }) {
    return TokenResponse(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'accessToken': accessToken,
      'refreshToken': refreshToken,
    };
  }

  factory TokenResponse.fromMap(Map<String, dynamic> map) {
    return TokenResponse(
      accessToken: map['accessToken'] as String,
      refreshToken: map['refreshToken'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory TokenResponse.fromJson(String source) =>
      TokenResponse.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'TokenResponse(accessToken: $accessToken, refreshToken: $refreshToken)';

  @override
  bool operator ==(covariant TokenResponse other) {
    if (identical(this, other)) return true;

    return other.accessToken == accessToken &&
        other.refreshToken == refreshToken;
  }

  @override
  int get hashCode => accessToken.hashCode ^ refreshToken.hashCode;
}
