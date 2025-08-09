import 'package:melo_desktop/models/role_response.dart';

class UserResponse {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? userName;
  final String? email;
  final String? phone;
  final bool? subscribed;
  final DateTime? subscriptionStart;
  final DateTime? subscriptionEnd;
  final bool? deleted;
  final List<RoleResponse> roles;

  UserResponse({
    required this.id,
    this.firstName,
    this.lastName,
    this.userName,
    this.email,
    this.phone,
    this.subscribed,
    this.subscriptionStart,
    this.subscriptionEnd,
    this.deleted,
    this.roles = const [],
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) {
    return UserResponse(
      id: json['id'] as int,
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      userName: json['userName'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      subscribed: json['subscribed'] as bool?,
      subscriptionStart: json['subscriptionStart'] != null
          ? DateTime.parse(json['subscriptionStart'] as String)
          : null,
      subscriptionEnd: json['subscriptionEnd'] != null
          ? DateTime.parse(json['subscriptionEnd'] as String)
          : null,
      deleted: json['deleted'] as bool?,
      roles: (json['roles'] as List<dynamic>?)
              ?.map((roleJson) =>
                  RoleResponse.fromJson(roleJson as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
