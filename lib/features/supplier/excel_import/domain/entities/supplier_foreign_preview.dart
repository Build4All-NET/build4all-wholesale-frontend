import 'package:equatable/equatable.dart';

/// One product the import would create, shown before it creates anything.
class SupplierForeignProductPreview extends Equatable {
  final int row;
  final String name;
  final String? description;
  final double? price;
  final int? stock;
  final int? moq;
  final String? categoryName;
  final String? imageUrl;

  /// False when something is missing the supplier would want to fix first.
  final bool valid;

  /// Codes, worded by the app in the reader's own language.
  final List<String> issues;
  final List<String> notes;

  const SupplierForeignProductPreview({
    required this.row,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.moq,
    required this.categoryName,
    required this.imageUrl,
    required this.valid,
    required this.issues,
    required this.notes,
  });

  @override
  List<Object?> get props => [
        row,
        name,
        description,
        price,
        stock,
        moq,
        categoryName,
        imageUrl,
        valid,
        issues,
        notes,
      ];
}

/// What an import would create, in full, before it creates any of it.
class SupplierForeignPreview extends Equatable {
  final List<SupplierForeignProductPreview> products;

  /// Rows that cannot become products, almost always because they have no name.
  /// Counted rather than listed: there is nothing in them to show.
  final int skippedRows;

  final int needingAttention;

  const SupplierForeignPreview({
    required this.products,
    required this.skippedRows,
    required this.needingAttention,
  });

  bool get isEmpty => products.isEmpty;

  @override
  List<Object?> get props => [products, skippedRows, needingAttention];
}
