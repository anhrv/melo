class IsLikedResponse {
  final bool isLiked;

  IsLikedResponse({
    required this.isLiked,
  });

  factory IsLikedResponse.fromJson(Map<String, dynamic> json) {
    return IsLikedResponse(isLiked: json['isLiked']);
  }
}
