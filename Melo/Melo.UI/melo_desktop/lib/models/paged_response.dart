class PagedResponse<T> {
  final int page;
  final int? prevPage;
  final int? nextPage;
  final int totalPages;
  final int totalItems;
  final int items;
  final List<T> data;

  PagedResponse({
    required this.page,
    this.prevPage,
    this.nextPage,
    required this.totalPages,
    required this.totalItems,
    required this.items,
    required this.data,
  });

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PagedResponse(
      page: json['page'],
      prevPage: json['prevPage'],
      nextPage: json['nextPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      items: json['items'],
      data: (json['data'] as List).map((e) => fromJsonT(e)).toList(),
    );
  }
}
