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
    final methodCode = (json['code'] ?? json['methodName'] ?? '').toString();
    final description =
        (json['helperText'] ?? json['description'] ?? '').toString();

    return SupplierPaymentMethodModel(
      id: _asInt(json['id']),
      code: methodCode,
      displayName: (json['displayName'] ?? methodCode).toString(),
      platformEnabled:
          json['platformEnabled'] == true || json['globallyEnabled'] == true,
      projectEnabled:
          json['projectEnabled'] == true || json['enabledForSupplier'] == true,
      supportedNow: json['supportedNow'] == true,
      requiresCredentials: json['requiresCredentials'] == true,
      helperText: description,
      configSchema: _asMap(json['configSchema']),
      configValues: _readConfigValues(json),
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

  static Map<String, dynamic> _readConfigValues(Map<String, dynamic> json) {
    final directConfigValues = json['configValues'];

    if (directConfigValues is Map) {
      return Map<String, dynamic>.from(directConfigValues);
    }

    final configJson = json['configJson'];

    if (configJson is String && configJson.trim().isNotEmpty) {
      return <String, dynamic>{
        'rawConfigJson': configJson,
      };
    }

    return <String, dynamic>{};
  }
}