import 'dart:typed_data';

import 'package:equatable/equatable.dart';

class SupplierPickedExcelFileEntity extends Equatable {
  final String fileName;
  final Uint8List bytes;

  const SupplierPickedExcelFileEntity({
    required this.fileName,
    required this.bytes,
  });

  @override
  List<Object?> get props => [fileName, bytes];
}
