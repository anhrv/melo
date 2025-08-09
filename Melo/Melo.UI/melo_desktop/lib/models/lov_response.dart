class LovResponse {
  final int id;
  final String name;

  LovResponse({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LovResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  factory LovResponse.fromJson(Map<String, dynamic> json) {
    return LovResponse(
      id: json['id'],
      name: json['name'],
    );
  }
}
