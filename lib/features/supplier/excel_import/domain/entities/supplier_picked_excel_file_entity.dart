import 'dart:typed_data';

class SupplierPickedExcelFileEntity {
  final String fileName;
  final Uint8List bytes;

  const SupplierPickedExcelFileEntity({
    required this.fileName,
    required this.bytes,
  });
}
