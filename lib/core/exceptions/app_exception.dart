class AppException implements Exception {
  final String message;
  final String? code;
  final Object? original;

  AppException(
    this.message, {
    this.code,
    this.original,
  });

  @override
  String toString() => message;
}