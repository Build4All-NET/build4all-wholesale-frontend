import '../../domain/entities/low_stock_alert_entity.dart';
import '../../../products/domain/entities/product_entity.dart';

class LowStockAlertModel extends LowStockAlertEntity {
  LowStockAlertModel({
    required super.inventoryId,
    required super.branchId,
    required super.branchName,
    required super.branchCity,
    required super.productId,
    required super.productName,
    required super.productDescription,
    required super.productPrice,
    required super.minimumOrderQuantity,
    required super.productStatus,
    super.productImageUrl,
    required super.categoryId,
    required super.categoryName,
    super.subCategoryId,
    super.subCategoryName,
    required super.stockQuantity,
    required super.alertLevel,
  });

  factory LowStockAlertModel.fromJson(Map<String, dynamic> json) {
    return LowStockAlertModel(
      inventoryId: json['inventoryId']?.toString() ?? '',
      branchId: json['branchId']?.toString() ?? '',
      branchName: json['branchName']?.toString() ?? '',
      branchCity: json['branchCity']?.toString() ?? '',
      productId: json['productId']?.toString() ?? '',
      productName: json['productName']?.toString() ?? '',
      productDescription: json['productDescription']?.toString() ?? '',
      productPrice: _toDouble(json['productPrice']),
      minimumOrderQuantity: _toInt(json['minimumOrderQuantity']),
      productStatus: _productStatusFromJson(json['productStatus']),
      productImageUrl: json['productImageUrl']?.toString(),
      categoryId: json['categoryId']?.toString() ?? '',
      categoryName: json['categoryName']?.toString() ?? '',
      subCategoryId: json['subCategoryId']?.toString(),
      subCategoryName: json['subCategoryName']?.toString(),
      stockQuantity: _toInt(json['stockQuantity']),
      alertLevel: _alertLevelFromJson(json['alertLevel']),
    );
  }

  static ProductStatus _productStatusFromJson(dynamic value) {
    final status = value?.toString().toUpperCase();

    if (status == 'INACTIVE') {
      return ProductStatus.inactive;
    }

    return ProductStatus.active;
  }

  static LowStockAlertLevel _alertLevelFromJson(dynamic value) {
    final level = value?.toString().toUpperCase();

    if (level == 'OUT_OF_STOCK') {
      return LowStockAlertLevel.outOfStock;
    }

    if (level == 'CRITICAL') {
      return LowStockAlertLevel.critical;
    }

    return LowStockAlertLevel.low;
  }

  static int _toInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  static double _toDouble(dynamic value) {
    if (value == null) return 0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0;
  }
}