import 'package:equatable/equatable.dart';

class SupplierExcelImportResultEntity extends Equatable {
  final int totalRows;
  final int importedCount;
  final int failedCount;
  final List<String> messages;
  final List<String> failedMessages;

  const SupplierExcelImportResultEntity({
    required this.totalRows,
    required this.importedCount,
    required this.failedCount,
    this.messages = const [],
    this.failedMessages = const [],
  });

  bool get isFullSuccess => failedCount == 0;
  bool get hasFailures => failedCount > 0;

  @override
  List<Object?> get props => [
        totalRows,
        importedCount,
        failedCount,
        messages,
        failedMessages,
      ];
}
