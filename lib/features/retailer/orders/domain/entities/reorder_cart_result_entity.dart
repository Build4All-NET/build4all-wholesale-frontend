class ReorderCartResultEntity {
  final int totalItems;
  final List<String> warnings;

  const ReorderCartResultEntity({
    required this.totalItems,
    this.warnings = const [],
  });
}
