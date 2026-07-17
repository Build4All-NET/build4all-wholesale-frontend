class PagedResult<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool hasNext;

  const PagedResult({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.hasNext,
  });

  factory PagedResult.empty({int page = 0, int size = 0}) {
    return PagedResult(
      content: const [],
      page: page,
      size: size,
      totalElements: 0,
      totalPages: 0,
      hasNext: false,
    );
  }

  factory PagedResult.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic> json) fromJsonT,
  ) {
    return PagedResult(
      content: (json['content'] as List<dynamic>? ?? [])
          .map((item) => fromJsonT(Map<String, dynamic>.from(item as Map)))
          .toList(),
      page: _toInt(json['page']),
      size: _toInt(json['size']),
      totalElements: _toInt(json['totalElements']),
      totalPages: _toInt(json['totalPages']),
      hasNext: json['hasNext'] == true,
    );
  }
}

int _toInt(dynamic value, {int fallback = 0}) {
  if (value == null) return fallback;
  if (value is int) return value;
  if (value is double) return value.toInt();
  return int.tryParse(value.toString()) ?? fallback;
}
