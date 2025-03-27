class RoleResponse {
  final int id;
  final String name;

  RoleResponse({required this.id, required this.name});

  factory RoleResponse.fromJson(Map<String, dynamic> json) {
    return RoleResponse(
      id: json['id'] as int,
      name: json['name'] as String,
    );
  }
}
