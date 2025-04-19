class LovResponse {
  final int id;
  final String name;

  LovResponse({
    required this.id,
    required this.name,
  });

  factory LovResponse.fromJson(Map<String, dynamic> json) {
    return LovResponse(
      id: json['id'],
      name: json['name'],
    );
  }
}
