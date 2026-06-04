import '../../domain/entities/supplier_payment_method_entity.dart';

class SupplierPaymentMethodModel extends SupplierPaymentMethodEntity {
  const SupplierPaymentMethodModel({
    required super.id,
    required super.code,
    required super.displayName,
    required super.platformEnabled,
    required super.projectEnabled,
    required super.supportedNow,
    required super.requiresCredentials,
    required super.helperText,
    required super.configSchema,
    required super.configValues,
    required super.updatedAt,
  });

  factory SupplierPaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return SupplierPaymentMethodModel(
      id: _asInt(json['id']),
      code: (json['code'] ?? '').toString(),
      displayName: (json['displayName'] ?? json['code'] ?? '').toString(),
      platformEnabled: json['platformEnabled'] == true,
      projectEnabled: json['projectEnabled'] == true,
      supportedNow: json['supportedNow'] == true,
      requiresCredentials: json['requiresCredentials'] == true,
      helperText: (json['helperText'] ?? '').toString(),
      configSchema: _asMap(json['configSchema']),
      configValues: _asMap(json['configValues']),
      updatedAt: _asDate(json['updatedAt']),
    );
  }

  static int? _asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  static DateTime? _asDate(dynamic value) {
    if (value == null) return null;
    return DateTime.tryParse(value.toString());
  }

  static Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return <String, dynamic>{};
  }
}
