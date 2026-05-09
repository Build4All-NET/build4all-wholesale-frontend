class SupplierExcelImportResultEntity {
  final int totalRows;
  final int importedCount;
  final int failedCount;
  final List<String> failedMessages;

  const SupplierExcelImportResultEntity({
    required this.totalRows,
    required this.importedCount,
    required this.failedCount,
    required this.failedMessages,
  });

  bool get hasFailures => failedCount > 0;
}
